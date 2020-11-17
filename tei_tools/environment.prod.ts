export const environment = {
	production: true,
	version: '0.9.0',
	server_url: 'https://kildeutgivelser.bratteng.com',
	api_url: 'https://api.kildeutgivelser.bratteng.com',
	api_url_path: 'digitaledition',
	project_default: 'topelius',
	project_default_id: 1,
	project_lock_id: 1,
	image_logo: 'logo.png',
	publisher_configuration: {
	  show_remove: false
	},
	selector_configurations: [
	  {
		name: 'Personer',
		type: 'subjects',
		descriptionField: 'Karriär',
		sortByColumn: 0,
		sortByField: 'last_name',
		elements: [
		  'persName', 'rs'
		],
		elementsXPath: '//*[name() = "persName" or name() = "rs"]',
		attribute: 'corresp'
	  },
	  {
		name: 'Platser',
		type: 'locations',
		descriptionField: 'Beskrivning',
		sortByColumn: 0,
		sortByField: 'name',
		elements: [
		  'placeName'
		],
		elementsXPath: '//*[name() = "placeName"]',
		attribute: 'corresp'
	  }
	],
	xml_file_extensions: '.xml,.tei,.txt',
	xml_space_before_trailing_slash: true,
	line_break: '\r\n',
	genres: [
	  { key: 'poetry', name: 'Poetry' },
	  { key: 'prose', name: 'Prose' },
	  { key: 'drama', name: 'Drama' },
	  { key: 'non-fiction', name: 'Non-fiction' },
	  { key: 'media', name: 'Media' }
	],
	published_levels: [
	  { key: 0, name: 'No' },
	  { key: 1, name: 'Internally' },
	  { key: 2, name: 'Externally' }
	]
  };
