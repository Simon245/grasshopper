Grasshopper.controller "SearchCtrl", ['$scope', '$location', 'User', '$http', ($scope, $location, User, $http) ->
  User.loadAll().then (result) ->
    $scope.users = result.users

  User.loadCurrentUser().then (data) ->
    $scope.currentUser = data.users[0]


  filterUsersCommunicatedWith = (data) ->
    communicatedUsers = []
    console.log '$scope.conversations: ', $scope.conversations = data.linked.conversations
    angular.forEach data.linked.conversations, (conversation) ->
      communicatedUsers.push conversation.created_by
      communicatedUsers.push conversation.created_for
    $scope.usersCommunicatedWith = _.pull(_.uniq(communicatedUsers), $scope.currentUser.id)

  $scope.search = () ->
    $location.url '/search'

  $scope.searchText = ''

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
      console.log 'create new conversation with this user'
      User.createConversationWithMessage($scope.currentUser, user, messageText).then (response) ->
        console.log 'location: ', response.headers('location')
        console.log 'successfully created conversation and message'
        $scope.usersCommunicatedWith.push user.id
    else
      console.log 'already had conversation with this user before'
      console.log $scope.conversations
      conversation = _.find($scope.conversations, (conversation) -> conversation.created_by == user.id || conversation.created_for == user.id)
      User.createMessageTo($scope.currentUser, user, messageText, conversation.id).success (response) ->
          console.log 'successfully created message'
]

