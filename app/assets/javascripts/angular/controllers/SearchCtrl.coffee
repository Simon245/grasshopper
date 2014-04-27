Grasshopper.controller "SearchCtrl", ['$scope', '$location', 'User', '$http', ($scope, $location, User, $http) ->

  reloadUser = () ->
    User.loadCurrentUser().then (data) ->
      $scope.currentUser = data.users[0]
      filterUsersCommunicatedWith(data)

  filterUsersCommunicatedWith = (data) ->
    communicatedUsers = []
    $scope.conversations = data.linked.conversations
    angular.forEach data.linked.conversations, (conversation) ->
      communicatedUsers.push conversation.created_by
      communicatedUsers.push conversation.created_for
    $scope.usersCommunicatedWith = _.pull(communicatedUsers, $scope.currentUser.id)

  $scope.search = () ->
    $location.url '/search'

  $scope.filterByNameOrSkill = (users,searchText) ->
    filteredUsers = []
    searchTextRegExp = RegExp(searchText, 'i')

    angular.forEach users, (user) ->
      if user.first_name.match(searchTextRegExp) or user.last_name.match(searchTextRegExp)
        isMatch = true
      else angular.forEach user.links.proficiencies, (proficiency) ->
        if proficiency.skill.match(searchTextRegExp)
          isMatch = true
      filteredUsers.push user if isMatch == true
    console.log searchText
    filteredUsers

  $("ul.nav.nav-pills.nav-justified li a").click () ->
    $(this).parent().addClass("active").siblings().removeClass "active"
    return

  $scope.submitMessage = (user, messageText) ->
    if _.indexOf($scope.usersCommunicatedWith, user.id) == -1 and user.id != $scope.currentUser.id
      User.createConversationWithMessage($scope.currentUser, user, messageText).success (response) ->
        noty { text: 'Successfully sent a message!', type: 'success'}
        console.log '$scope.messageText: ', $scope.messageText = ''
        $scope.usersCommunicatedWith.push user.id
        reloadUser()
      .error (response) ->
        noty { text: 'Message cannot be sent! Please try again', type: 'error'}
    else
      conversation = _.find($scope.conversations, (conversation) -> conversation.created_by == user.id || conversation.created_for == user.id)
      User.createMessageTo($scope.currentUser, user, messageText, conversation.id).success (response) ->
        noty { text: 'Successfully sent a message!', type: 'success'}
        console.log '$scope.messageText: ', $scope.messageText = ''
      .error (response) ->
        noty { text: 'Message cannot be sent! Please try again', type: 'error'}
    $(".modal").modal('hide')
    return

  User.loadAll().then (result) ->
    $scope.users = result.users

  reloadUser()

  $scope.messageText = ''

  $scope.searchText = ''

]

