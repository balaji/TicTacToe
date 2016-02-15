"use strict";

/**
 * Function to return the total number of wins for the given player ID
 * @param playerId
 * @returns {number} - number of wins.
 */
exports.getWins = function (playerId) {
    if (window.localStorage) {
        return window.localStorage.getItem(playerId + ":wins") || 0;
    }
    return 0;
};

/**
 * Function to increment the total number of wins for the give player ID by 1
 * @param playerId
 */
exports.updateWins = function (playerId) {
    if (window.localStorage) {
        var key = playerId + ":wins";
        var wins = window.localStorage.getItem(key) || 0;
        window.localStorage.setItem(key, Number(wins) + 1);
    }
};

/**
 * Function to return the total number of draws for the given game session
 * @returns {number}
 */
exports.getDraws = function () {
    if (window.localStorage) {
        return window.localStorage.getItem("draws") || 0;
    }
    return 0;
};

/**
 * Function to update the total number of draws in the game session by 1
 */
exports.updateDraws = function () {
    if (window.localStorage) {
        var draws = window.localStorage.getItem("draws") || 0;
        window.localStorage.setItem("draws", Number(draws) + 1);
    }
};

/**
 * Function to retrieve the player name, given the player ID
 * @param playerId
 * @returns {*} - Player name.
 */
exports.getPlayerName = function (playerId) {
    var defaultNames = {"a": "Player 1", "b": "Player 2"};
    if (window.localStorage) {
        return window.localStorage.getItem(playerId) || defaultNames[playerId];
    }
    return defaultNames[playerId];
};

/**
 * Function to store a new name for the given player ID.
 * @param playerId
 * @param newName
 */
exports.updatePlayerName = function (playerId, newName) {
    if (window.localStorage) {
        window.localStorage.setItem(playerId, newName);
    }
};
