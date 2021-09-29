# Git-SVN Synctool
- Tool for syncing files between an SVN primary repo and a Git secondary, optionally into a subfolder
- Changes in Git repo are synced back to SVN
- On conflicting changes, entire file is synced from SVN to Git, overwriting changes
- See example_config.yml for example config

## Usage
- Set up a python virtualenv - `virtualenv venv`
- Activate the virtualenv - `source venv/bin/activate`
- Install requirements - `pip install -r requirements.txt`
- See python main.py -h
- python main.py <config_filename>

## Dockerfile
- Adds all files in the current folder to the docker image
- Suitable mainly for testing, sets up local "remotes" and working copies matching test_config.yml
    - SVN remote in /svn_remote
    - Git remote in /remote.git
    - SVN local in /tmp/svn
    - Git local in /tmp/git

## Technical details
- Sync is maintained using working copies in the application directory
- Any changes in either repo since the last time the script was run is assumed to not be in the configured remotes
