exec = require('child_process').exec
fs = require 'fs'
ncp = require 'ncp'
rimraf = require 'rimraf'
jf = require 'jsonfile'
Q = require 'q'
colors = require 'colors'

module.exports = (env) ->
	(plugin_repo, cwd, force) ->
		defer = Q.defer()
		if not plugin_repo?
			return env.debug 'Please provide a repository address for the plugin to install'
		temp_location = cwd + '/plugins/cloned'

		rimraf temp_location, (err) ->
			return defer.reject(err) if err
			fs.mkdirSync temp_location
			plugin_repo_str = plugin_repo.split("^")
			plugin_repo = plugin_repo_str[0]
			tag_name = null
			if plugin_repo_str.length > 1
				tag_name = plugin_repo_str[1]
			env.debug "Cloning " + plugin_repo.red
			command = 'cd ' + temp_location + '; git clone ' + plugin_repo + ' ' + temp_location
			if force 
				command += '; git checkout tags/' + tag_name
			exec command, (error, stdout, stderr) ->
				# throw error if error
				return defer.reject error if error
				env.debug "Loading plugin information"
				try
					plugin_data = JSON.parse(fs.readFileSync temp_location + '/plugin.json', { encoding: 'UTF-8' })
				catch e 
					return defer.reject e
				folder_name = cwd + "/plugins/" + plugin_data.name
				rimraf folder_name, (err) ->
					return defer.reject(err) if err
					fs.rename cwd + '/plugins/cloned', cwd + '/plugins/' + plugin_data.name, (err) ->
						return defer.reject(err) if err
						env.debug 'Plugin "' + plugin_data.name + '" successfully installed in "'+ folder_name + '".'
						
						file =  cwd + '/plugins.json'
						jf.spaces = 4

						jf.readFile file, (err, obj) ->
							return defer.reject(err) if err
							if not obj?
								obj = {}
							if (not obj[plugin_data.name]?) # only add entry to plugins.json if not already there
								obj[plugin_data.name] = plugin_repo
								jf.writeFile file, obj, (err) ->
									return defer.reject(err) if err
									env.debug 'Plugin "' + plugin_data.name + '" successfully added to the plugins list.'
									defer.resolve()
							else
								defer.resolve()


		defer.promise