tk = require('timekeeper')
testConfig = require '../../test-config'
coreModule = require testConfig.project_root + '/src/core'
dataModule = require testConfig.project_root + '/src/data'
async = require 'async'
describe 'Data - apps module', () ->

	env = {
		mode: 'test'
	}
	
	suffix = '0'
	beforeEach () ->
		env = {
			mode: 'test'
		}
		coreModule(env).initEnv()
		coreModule(env).initConfig()
		coreModule(env).initUtilities()
		dataModule(env)

		env.data.generateUid = () ->
			return 'someuid' + suffix

	it 'Application creation - env.data.apps.create (success case)', (done) ->
		
		expect(env.data.apps.create).toBeDefined()
		suffix = '-0'
		env.data.apps.create { name: 'myapp' }, { id: 1 }, (err, app) ->
			expect(err).toBe(null)
			expect(typeof app).toBe('object')
			expect(typeof app.id).toBe('number')
			expect(app.name).toBe('myapp')
			expect(app.key).toBe('someuid-0')

			env.data.redis.mget [
				'a:' + app.id + ':name',
				'a:' + app.id + ':key',
				'a:' + app.id + ':secret',
				'a:' + app.id + ':owner',
				'a:' + app.id + ':date'
			],  (err, result) ->
				expect(err).toBe(null)
				expect(result[0]).toBe('myapp')
				expect(result[1]).toBe('someuid-0')
				expect(result[2]).toBe('someuid-0')
				expect(result[3]).toBe('1')
				expect(result[4]).toMatch(/^[0-9]+$/)

				env.data.redis.hget 'a:keys', 'someuid-0', (err, id) ->
					expect(id).toBe(app.id)
					done()

	it 'Application creation - env.data.apps.create (error cases)', (done) ->
		suffix = '-0'

		async.series [
			(next) ->
				env.data.apps.create undefined, { id: 1 }, (err, app) ->
					expect(err).toBeDefined()
					expect(app).toBeUndefined()
					expect(err.message).toBe('You must specify a name for your application')
					next()
			(next) ->
				env.data.apps.create {name:'myapp'}, undefined, (err, app) ->
					expect(err).toBeDefined()
					expect(app).toBeUndefined()
					expect(err.message).toBe('The user must be defined and contain the field \'id\'')
					next()
			(next) ->
				env.data.apps.create {name: undefined}, { id: 1 }, (err, app) ->
					expect(err).toBeDefined()
					expect(app).toBeUndefined()
					expect(err.message).toBe('You must specify a name for your application')
					next()
			(next) ->
				env.data.apps.create {name:'myapp'}, {id: undefined}, (err, app) ->
					expect(err).toBeDefined()
					expect(app).toBeUndefined()
					expect(err.message).toBe('The user must be defined and contain the field \'id\'')
					next()
		], (err) ->
			done()

	it 'Application retrieval by owner - env.data.apps.getByOwner (success case)', (done) ->
		suffix = '-1'
		env.data.apps.create {name:'myapp'}, { id: 5 }, (err, app) ->
			expect(err).toBeNull()
			env.data.apps.getByOwner 5, (err, apps) ->
				expect(err).toBeNull()
				app = apps[0]
				expect(typeof app).toBe('object')
				expect(app.name).toBe('myapp')
				expect(app.key).toBe('someuid-1')
				expect(app.secret).toBe('someuid-1')
				expect(app.owner).toBe('5')
				done()

	it 'Application retrieval by owner - env.data.apps.getByOwner (error cases)', (done) ->
		suffix = '-1'
		env.data.apps.create {name:'myapp'}, { id: 6 }, (err, app) ->
			expect(err).toBeNull()
			env.data.apps.getByOwner 6, (err, apps) ->
				expect(apps.length).toBe(1)
				done()


	it 'Application retrieval by id - env.data.apps.getById', (done) ->
		suffix = '-2'
		env.data.apps.create {name:'myapp'}, { id: 1 }, (err, app) ->
			expect(err).toBeNull()
			env.data.apps.getById app.id, (err, app2) ->
				expect(err).toBeNull()
				expect(typeof app2).toBe('object')
				expect(app2.name).toBe('myapp')
				expect(app2.owner).toBe('1')
				expect(app2.id).toBe(app.id)
				expect(app2.key).toBe('someuid-2')
				expect(app2.secret).toBe('someuid-2')
				done()

	xit 'Application update by id - env.data.apps.get', (done) ->
		done()

	xit 'Application key reset - env.data.apps.get', (done) ->
		done()

	xit 'Application removal - env.data.apps.get', (done) ->
		done()

	xit 'Application domain update - env.data.apps.updateDomains', (done) ->
		done()

	xit 'Application domain add - env.data.apps.addDomain', (done) ->
		done()

	xit 'Application domain retrieval - env.data.apps.getDomains', (done) ->
		done()

	xit 'Application domain removal - env.data.apps.remDomain', (done) ->
		done()

	xit 'Application backend set - env.data.apps.setBackend', (done) ->
		done()

	xit 'Application backend check - env.data.apps.checkDomain', (done) ->
		done()

	xit 'Application owner retrieval - env.data.apps.getOwner', (done) ->
		done()

	xit 'Application secret check - env.data.apps.checkSecret', (done) ->
		done()