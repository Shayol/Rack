var racker = angular.module('Racker', [], function($httpProvider) {
  // Use x-www-form-urlencoded Content-Type
  $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';

  /**
   * The workhorse; converts an object to x-www-form-urlencoded serialization.
   * @param {Object} obj
   * @return {String}
   */
  var param = function(obj) {
    var query = '', name, value, fullSubName, subName, subValue, innerObj, i;

    for(name in obj) {
      value = obj[name];

      if(value instanceof Array) {
        for(i=0; i<value.length; ++i) {
          subValue = value[i];
          fullSubName = name + '[' + i + ']';
          innerObj = {};
          innerObj[fullSubName] = subValue;
          query += param(innerObj) + '&';
        }
      }
      else if(value instanceof Object) {
        for(subName in value) {
          subValue = value[subName];
          fullSubName = name + '[' + subName + ']';
          innerObj = {};
          innerObj[fullSubName] = subValue;
          query += param(innerObj) + '&';
        }
      }
      else if(value !== undefined && value !== null)
        query += encodeURIComponent(name) + '=' + encodeURIComponent(value) + '&';
    }

    return query.length ? query.substr(0, query.length - 1) : query;
  };

  // Override $http service's default transformRequest
  $httpProvider.defaults.transformRequest = [function(data) {
    return angular.isObject(data) && String(data) !== '[object File]' ? param(data) : data;
  }];
});


racker.controller('RackerController', ['$scope', '$http', function($scope, $http) {
  $scope.guesses = [];
  $scope.update_guess = '';
  $scope.hint = '';
  $scope.user = '';
  $scope.gameProgressing = true;
  $scope.won = false;
  $scope.lost = false;

  $scope.guess = function() {
    $http.post('/update_guess', {guess: $scope.update_guess}).
      success(function(data, status, headers, config) {
        $scope.guesses.push(data);
        if(data.result == "++++" || data.result == "lost") {
          $scope.gameProgressing = false;
          (data.result == "++++") ? $scope.won = true : $scope.lost = true;
        }
        $scope.update_guess = '';
      }).
      error(function(data, status, headers, config) {
        console.log("Update_guess returned error");
      });

  };

  $scope.createUser = function() {
    $http.post('/create_user', {user: $scope.user}).
      success(function(data, status, headers, config) {
         $scope.won = false;
         $scope.user = '';
         $scope.newGame();
      }).
      error(function(data, status, headers, config) {
        console.log("CreateUser returned error");
      });

  };

  $scope.getHint = function() {
  $http.get('/get_hint', {guess: $scope.update_guess}).
    success(function(data, status, headers, config) {
      $scope.hint = data.hint;
    }).
    error(function(data, status, headers, config) {
      console.log("Mistake while waiting for hint");
    });
  };

  $scope.newGame = function() {
  $http.post('/new_game', {}).
    success(function(data, status, headers, config) {
      $scope.hint = '';
      $scope.guesses = [];
      $scope.gameProgressing = true;
      $scope.won = false;
      $scope.lost = false;
    }).
    error(function(data, status, headers, config) {
      console.log("New game wasn't started.")
    });
  };


}]);







