var racker = angular.module('Racker', []);

racker.controller('RackerController', ['$scope', '$http', function($scope, $http) {
  $scope.guesses = [];
  $scope.update_guess = '';
  $scope.guess = function() {

    // $http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
    $http.post('/update_guess', {guess: $scope.update_guess}).
      success(function(data, status, headers, config) {
        $scope.guesses.push(data);
        $scope.update_guess = '';
      }).
      error(function(data, status, headers, config) {
        console.log("update_guess returned error");
      });


  };
}]);







