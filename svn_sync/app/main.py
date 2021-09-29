import argparse
import logging
import os
import shutil
import subprocess
import sys
import traceback

try:
    from dotenv import load_dotenv

    load_dotenv()
except ModuleNotFoundError:
    print("Failed to load dotenv file. Assuming production")


def run_command_and_return_output(command_list, working_folder=None):
    """
    Runs the command (given as a list, containing the command and eventual arguments) in the given working directory
    Returns the command output as a list of lines, captured from stdout
    """
    output = subprocess.check_output(command_list, cwd=working_folder)
    output = [s.strip().decode("utf-8", errors="ignore")
              for s in output.splitlines()]
    return output


svn_username = os.getenv("SVN_USERNAME")
svn_password = os.getenv("SVN_PASSWORD")
svn_remote = os.getenv("SVN_REMOTE")

git_remote = os.getenv("GIT_REMOTE")
git_subfolder = os.getenv("GIT_SUBFOLDER")


class GitSVNSyncTool(object):
    def __init__(self, log_level, init):
        self.svn = ["svn", "--non-interactive"]
        self.initialize_new_git_repo = init

        # Set up logging
        self.logger = logging.getLogger("sync_tool")
        numeric_log_level = getattr(logging, log_level.upper())
        self.logger.setLevel(numeric_log_level)
        log_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s', '%H:%M:%S')
        stream_handler = logging.StreamHandler(sys.stdout)
        stream_handler.setFormatter(log_formatter)
        self.logger.addHandler(stream_handler)

        # Set up an easy shorthand for SVN commands
        if svn_username is not None and svn_password is not None:
            self.svn += ["--username", svn_username]
            self.svn += ["--password", svn_password]
            self.svn += ["--no-auth-cache"]

        # Set up working copies to use for syncing
        self.git_local_root = os.path.join(os.getcwd(), "git_repo")
        if not os.path.exists(self.git_local_root):
            # if there's no local git repo, assume this is the first run. initialize from SVN.
            self.initialize_new_git_repo = True
            self.logger.info(
                "Will sync all files, as this is a first run (no local git working copy exists)")
            clone = run_command_and_return_output(
                ["git", "clone", "--depth", "1", git_remote, self.git_local_root])
            self.logger.debug(
                "Cloned remote git repo: {!r}".format("; ".join(clone)))

        self.svn_local_root = os.path.join(os.getcwd(), "svn_repo")
        if not os.path.exists(self.svn_local_root):
            cmd = list(self.svn)
            cmd += ["checkout", svn_remote, self.svn_local_root]
            checkout = run_command_and_return_output(cmd)
            self.logger.debug(
                "Checked out remote SVN repo: {!r}".format("; ".join(checkout)))

    def get_git_changes(self):
        current_commit_hash = subprocess.check_output(
            ["git", "-C", self.git_local_root, "rev-parse", "--short", "HEAD"])
        current_commit_hash = current_commit_hash.strip().decode("utf-8", "ignore")
        subprocess.check_output(["git", "-C", self.git_local_root, "fetch"])

        # Get changes/commits since last update
        commits = run_command_and_return_output(["git", "-C", self.git_local_root, "log",
                                                 "--no-merges", "--pretty=format:%s", "..origin/master"])
        commits = list(reversed(commits))

        self.logger.debug("Git commits since {}: {!r}".format(
            current_commit_hash, " | ".join(commits)))
        # Get changed files
        changed_files = []
        if not len(commits) == 0:
            changed_files = run_command_and_return_output(["git", "-C", self.git_local_root, "show",
                                                           "--pretty=format:", "--name-only", "..origin/master"])
            self.logger.debug("Git changes since {}: {!r}".format(
                current_commit_hash, ", ".join(changed_files)))

        # don't return changes that aren't in the git subfolder if one is defined (this is so we don't sync irrelevant files to SVN)
        if git_subfolder is not None:
            changed_files = [f for f in changed_files if f.startswith(
                git_subfolder)]

        return changed_files

    def get_current_svn_revision(self):
        output = run_command_and_return_output(
            ["svn", "info"], working_folder=self.svn_local_root)
        for line in output:
            if line.startswith("Revision"):
                return line.split(" ")[1]

    def get_svn_changes(self):
        # Get current revision we are on
        current_svn_revision = self.get_current_svn_revision()

        cmd = list(self.svn)
        cmd += ["diff", "-r",
                "{}:HEAD".format(current_svn_revision), "--summarize"]

        output = subprocess.check_output(cmd, cwd=self.svn_local_root)
        changed_files = [s.strip().decode("utf-8", "ignore").split(" ")[-1]
                         for s in output.splitlines()]
        # svn diff --summarize returns a list of file names preceded by the type of change (A/M/U/?) and ~6 spaces
        # splitting on space and getting last should give a list of just file names
        self.logger.debug("SVN changes since revision {}: {!r}".format(
            current_svn_revision, ", ".join(changed_files)))
        return changed_files

    def update_git_from_remote(self):
        """
        Returns true/false, error info if any, and repo status
        (True, None, <git status output>)
        (False, <commit messages containing fault>, <git status output>)
        """
        return_code = subprocess.check_call(
            ["git", "-C", self.git_local_root, "pull"])
        if return_code != 0:
            error_info = run_command_and_return_output(["git", "-C", self.git_local_root, "log",
                                                        "--no-merges", "--pretty=format:%s", "..origin/master"])
            error_info = list(reversed(error_info))
            self.logger.debug(error_info)
        else:
            error_info = None

        status = run_command_and_return_output(
            ["git", "-C", self.git_local_root, "status"])
        self.logger.debug(status)
        return error_info is None, error_info, status

    def update_svn_from_remote(self):
        """
        Returns true/false, error info if any, and repo status
        (True, None, <svn status output>)
        (False, <svn update return code and output>, <svn status output>)
        """
        try:
            update = list(self.svn) + ["update"]
            update_return = run_command_and_return_output(
                update, working_folder=self.svn_local_root)
            self.logger.debug(update_return)
        except subprocess.CalledProcessError:
            error_info = traceback.format_exc()
            self.logger.error(
                "Error during SVN update - {}".format(error_info))
        else:
            error_info = None
        status = list(self.svn) + ["status"]
        status = run_command_and_return_output(
            status, working_folder=self.svn_local_root)
        self.logger.debug(status)
        return error_info is None, error_info, status

    def sync_file_locally(self, source_root, source_file_path, target_root):
        # if the file wanting to be synced no longer exists in the source, it's likely because it's been deleted in a commit
        # make sure it's removed in the target as well
        if not os.path.exists(os.path.join(source_root, source_file_path)):
            if os.sep in source_file_path:
                dir_structure = os.path.dirname(source_file_path)
                try:
                    os.remove(os.path.join(target_root, dir_structure,
                              os.path.basename(source_file_path)))
                except FileNotFoundError:
                    pass
            else:
                try:
                    os.remove(os.path.join(
                        target_root, os.path.basename(source_file_path)))
                except FileNotFoundError:
                    pass
        # if the file still exists in the source, copy it over to the target
        else:
            if os.path.isdir(os.path.join(source_root, source_file_path)):
                os.makedirs(os.path.join(
                    target_root, source_file_path), exist_ok=True)
            else:
                if os.sep in source_file_path:
                    dir_structure = os.path.dirname(source_file_path)
                    os.makedirs(os.path.join(
                        target_root, dir_structure), exist_ok=True)
                    self.logger.debug("Copying {} from {} to {}/{}".format(
                        source_file_path, source_root, target_root, dir_structure))
                    shutil.copy2(os.path.join(source_root, source_file_path), os.path.join(
                        target_root, dir_structure))
                else:
                    self.logger.debug("Copying file {} from {} to {}".format(
                        source_file_path, source_root, target_root))
                    shutil.copy2(os.path.join(
                        source_root, source_file_path), target_root)

    def git_to_svn(self, file_list):
        svn_update_success, svn_error, svn_status = self.update_svn_from_remote()
        git_update_success, git_error, git_status = self.update_git_from_remote()
        add = list(self.svn) + ["add", "--force"]
        commit = list(self.svn) + ["commit", "-m", "\"Sync from Git\""]
        update = list(self.svn) + ["update"]
        if svn_update_success and git_update_success:
            for file in file_list:
                self.logger.debug("Filename: '{}'".format(file))
                if git_subfolder is not None:
                    # If this file is outside the git subfolder, ignore it
                    if file.split(os.sep)[0] != git_subfolder:
                        continue

                    # If there is a git_subfolder defined, we need to make sure the file structure in it is synced to SVN without making a subfolder for it.
                    # Thus, strip out git_subfolder from the filepath
                    file_no_git_subfolder = file.split(
                        git_subfolder)[-1].lstrip(os.sep)
                    source_file = os.path.join(self.git_local_root, file)
                    target_file = os.path.join(
                        self.svn_local_root, file_no_git_subfolder)

                    # if there is os.sep in the new filepath, it has a folder structure, recreate it in the svn_local_root and add to SVN's index
                    if os.sep in file_no_git_subfolder:
                        self.logger.debug("Creating folder structure {} in {}".format(
                            os.path.dirname(file_no_git_subfolder), self.svn_local_root))
                        os.makedirs(os.path.join(self.svn_local_root, os.path.dirname(
                            file_no_git_subfolder)), exist_ok=True)
                        add_return = run_command_and_return_output(
                            add + [os.path.dirname(file_no_git_subfolder)], working_folder=self.svn_local_root)
                        self.logger.debug("SVN add: {}".format(add_return))

                    # finally, copy the file from the git subfolder source to SVN and add it to the index
                    self.logger.debug("Copying {} to {}".format(
                        source_file, target_file))
                    shutil.copy2(source_file, target_file)
                    add_return = run_command_and_return_output(
                        add + [file.split(git_subfolder + "/")[-1]], working_folder=self.svn_local_root)
                else:
                    # if there is no git_subfolder, the git and svn repos are essentially identical and can just be synced as-is
                    self.sync_file_locally(
                        self.git_local_root, file, self.svn_local_root)
                    add_return = run_command_and_return_output(
                        add + [file], working_folder=self.svn_local_root)
                self.logger.debug("SVN add: {}".format(add_return))
            commit_return = run_command_and_return_output(
                commit, working_folder=self.svn_local_root)
            self.logger.debug("SVN commit: {}".format(commit_return))
            update_return = run_command_and_return_output(
                update, working_folder=self.svn_local_root)
            self.logger.debug("SVN update: {}".format(update_return))
        else:
            if not svn_update_success:
                self.logger.error("Error in SVN update - {}".format(svn_error))
                self.logger.error(
                    "Current local SVN repo status - {}".format(svn_status))
            if not git_update_success:
                self.logger.error("Error in Git pull - {}".format(git_error))
                self.logger.error(
                    "Current local Git repo status - {}".format(git_status))

    def svn_to_git(self, file_list):
        svn_update_success, svn_error, svn_status = self.update_svn_from_remote()
        git_update_success, git_error, git_status = self.update_git_from_remote()
        if svn_update_success and git_update_success:
            for file in file_list:
                # sync files from svn local root to git local root
                if git_subfolder is not None:
                    self.sync_file_locally(self.svn_local_root, file, os.path.join(
                        self.git_local_root, git_subfolder))
                else:
                    self.sync_file_locally(
                        self.svn_local_root, file, self.git_local_root)

            # run git add command
            if git_subfolder is not None:
                add_return = run_command_and_return_output(
                    ["git", "-C", self.git_local_root, "add", git_subfolder])
            else:
                add_return = run_command_and_return_output(
                    ["git", "-C", self.git_local_root, "add", "."])
            self.logger.debug("Git add: {}".format(add_return))

            # run git commit command
            commit_return = run_command_and_return_output(["git", "-C", self.git_local_root,
                                                           "commit", "-m", "Sync from SVN"])
            self.logger.info("Git commit: {}".format(commit_return))

            # run git push command
            push_return = run_command_and_return_output(
                ["git", "-C", self.git_local_root, "push"])
            self.logger.info("Git push: {}".format(push_return))
        else:
            if not svn_update_success:
                self.logger.error("Error in SVN update - {}".format(svn_error))
                self.logger.error(
                    "Current local SVN repo status - {}".format(svn_status))
            if not git_update_success:
                self.logger.error("Error in Git pull - {}".format(git_error))
                self.logger.error(
                    "Current local Git repo status - {}".format(git_status))

    def sync_changes(self):
        git_changes = self.get_git_changes()
        svn_changes = self.get_svn_changes()

        # Use a set to check, it's significantly faster than membership checking against a list
        temp = set(svn_changes)
        conflicts = [change for change in git_changes if change in temp]

        if self.initialize_new_git_repo:
            git_changes = []
            conflicts = []
            self.logger.info(
                "Ignoring data in Git repository as requested, syncing all files in SVN repo...")
            # includes directories as separate lines, ending with /
            all_svn_files = subprocess.check_output(
                list(self.svn) + ["ls", "-R", svn_remote])
            all_svn_files = [s.decode("utf-8", "ignore")
                             for s in all_svn_files.splitlines()]
            self.logger.debug("All SVN files: {}".format(
                ", ".join(all_svn_files)))
            svn_files = []
            for file in all_svn_files:
                if file.endswith("/"):
                    self.logger.debug("Creating folder {}".format(file))
                    if git_subfolder is None:
                        os.makedirs(os.path.join(
                            self.git_local_root, file), exist_ok=True)
                    else:
                        os.makedirs(os.path.join(
                            self.git_local_root, git_subfolder, file), exist_ok=True)
                else:
                    svn_files.append(file)
            svn_changes = list(svn_files)

        if len(git_changes) == 0 and len(svn_changes) == 0:
            self.logger.info("No changes.")
            return
        elif len(git_changes) == 0 and len(svn_changes) > 0:
            # Sync changes from SVN to Git
            self.logger.info("Syncing to git: {}".format(
                ", ".join(svn_changes)))
            self.svn_to_git(svn_changes)
        elif len(git_changes) > 0 and len(svn_changes) == 0:
            # Sync changes from Git to SVN
            if git_subfolder is not None:
                self.logger.info(
                    "Skipping sync for files not in masterfiles directory...")
                git_changes = [file for file in git_changes if file.startswith(
                    git_subfolder)]
            self.logger.info("Syncing to SVN: {}".format(
                ", ".join(git_changes)))
            self.git_to_svn(git_changes)
        else:
            # Changes in both repositories, try to resolve things
            if len(conflicts) == 0:
                # If there are no conflicts, just try to sync.
                # Things should work out, since we don't care much about history.
                self.logger.info("No conflicts.")
                self.logger.info("Syncing to git: {}".format(
                    ", ".join(svn_changes)))
                self.svn_to_git(svn_changes)
                if git_subfolder is not None:
                    self.logger.info(
                        "Skipping sync for files not in masterfiles directory...")
                    git_changes = [file for file in git_changes if file.startswith(
                        git_subfolder)]
                self.logger.info("Syncing to SVN: {}".format(
                    ", ".join(git_changes)))
                self.git_to_svn(git_changes)
            else:
                # Potential conflicts
                # SVN is master
                # SVN changes that are also in git changes are are overwritten in git (simply sync all SVN changes to git)
                # git changes that aren't in SVN changes are synced to SVN, conflicts are simply not synced (edits are thus "discarded")
                self.logger.warning(
                    "Possibly conflicting changes in {}".format(", ".join(conflicts)))
                self.logger.info("Syncing to git: {}".format(
                    ", ".join(svn_changes)))
                self.svn_to_git(svn_changes)
                git_okays = [
                    change for change in git_changes if change not in set(svn_changes)]
                self.logger.info(
                    "Syncing to SVN: {}".format(", ".join(git_okays)))
                self.git_to_svn(git_okays)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="SyncTool - For syncing SVN masterfiles into a Git repo and eventual changes back.")
    parser.add_argument("-l", "--log-level",
                        help="Logging level, defaults to INFO", default="INFO")
    parser.add_argument(
        "--init", help="Ignore all data in the git repo and simply sync over all files in the SVN repo.", action="store_true")

    args = parser.parse_args()

    sync_tool = GitSVNSyncTool(args.log_level, args.init)
    sync_tool.sync_changes()
