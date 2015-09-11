derby = require 'derby'
_ = require 'lodash'

app = module.exports = derby.createApp 'app', __filename

app.use require 'derby-debug'
app.serverUse module, 'derby-jade'
app.serverUse module, 'derby-stylus'

app.loadViews __dirname + '/views'
app.loadStyles __dirname + '/styles'

app.get '/', (page, model) ->

  model.subscribe "users.me", ->
    model.ref '_page.user', "users.me"

    products = model.query "products", '_page.user.productIds'

    model.subscribe products, ->
      model.ref '_page.products', products
      page.render 'root'

app.get '/home', (page, model) ->
  products = model.query "products", {}

  model.subscribe products, "users.me", ->
    model.ref '_page.products', products
    model.ref '_page.user', "users.me"
    page.render 'home'

app.proto.submit = (name) ->

  @model.add "products",

    name: name

app.proto.remove = (itemId) ->

  @model.del "products.#{ itemId }"

app.proto.getSetChecked =
  get: (product, productIds = []) ->
    product.id in productIds

  set: (value, product, productIds = []) ->

    res = _.cloneDeep(productIds)

    if value

      res.push(product.id) unless product.id in productIds

    else
      index = productIds.indexOf(product.id)

      res.splice(index, 1) if index >= 0

    {1: res}

