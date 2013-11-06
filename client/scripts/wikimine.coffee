
#
# CONTROLLERS
#-------------------------
# We have to do all this in one file because of Coffee's overblown anti-global cleverness and because I don't want to
# bring another vendor plugin into the mix for what should be relatively simple functionality
#


# Default Controller
DefaultController =
  index: (count) ->
    $("span#changes_count").html(count)

AuthorsController =
  index: (count) ->
    $("span#authors_count").html(count)

VolumeController =
  index: (count) ->
    $("span#volume_count").html(count)

#
# APPLICATION
# ----------------------
#

socket = io.connect('http://localhost:8008')
socket.on 'connected', ->
  socket.emit 'request', {
    controller: 'default'
    method: 'index'
  }

  socket.emit 'request', {
    controller: 'authors'
    method: 'index'
  }

router =
  default: DefaultController
  authors: AuthorsController
  volume: VolumeController

socket.on 'response', (data) ->
  router[data.controller][data.method](data.body)

