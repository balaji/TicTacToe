"use strict";

var React = require("react");
var ReactDOM = require("react-dom");
var jQuery = require("jquery");

var Square = React.createClass({
    playGame: function () {
        if (this.props.value !== "-" || this.props.gameStatus !== "in_progress") {
            return;
        }
        var url = "/" + window.Globals.GameID + "/mark.json";
        jQuery.ajax({
            url: url,
            dataType: "json",
            cache: false,
            method: "POST",
            data: {"row": this.props.row, "column": this.props.column},
            success: function (data) {
                if (data.game_status.state === "won") {
                    updateWins(data.next_turn === "a" ? "b" : "a");
                }
                if (data.game_status.state === "draw") {
                    updateDraws();
                }
                // Re-render parent with updated data.
                ReactDOM.render(<Grid data={data}/>, document.getElementById("content"));
            },
            error: function (xhr, status, err) {
                console.error(url, status, err.toString());
            }
        });
    },
    render: function () {
        var className = "square";
        if (this.props.value !== "-") {
            className = "square_occupied";
        }
        if (this.props.winnerBlock) {
            className += " winner";
        }
        return (
            <div className={className}
                 data-row={this.props.row} data-column={this.props.column}
                 onClick={this.playGame}>
                {this.props.value}
            </div>
        );
    }
});

var Player = React.createClass({
    render: function () {
        var className = "player";
        if (this.props.id === this.props.next_turn) {
            className += " active";
        }
        return (
            <div className={className}>{this.props.name}</div>
        );
    }
});

var getPlayerName = function (playerId) {
    var defaultNames = {"a": "Player 1", "b": "Player 2"};
    if (window.localStorage) {
        return window.localStorage.getItem(playerId) || defaultNames[playerId];
    }
    return defaultNames[playerId];
};

var updateWins = function (playerId) {
    if (window.localStorage) {
        var key = playerId + ":wins";
        var wins = window.localStorage.getItem(key) || 0;
        window.localStorage.setItem(key, Number(wins) + 1);
    }
};

var updateDraws = function () {
    if (window.localStorage) {
        var draws = window.localStorage.getItem("draws") || 0;
        window.localStorage.setItem("draws", Number(draws) + 1);
    }
};

var getWins = function (playerId) {
    return window.localStorage.getItem(playerId + ":wins") || 0;
};

var getDraws = function () {
    return window.localStorage.getItem("draws") || 0;
};

var LeaderBoard = React.createClass({
    render: function () {
        var winner = function (data) {
            var winnerText = "&nbsp;";
            if (data.status === "won") {
                winnerText = "Game Won. Congratulations!!! <br><strong>" + getPlayerName(data.player) + "</strong>";
            } else if (data.status === "draw") {
                winnerText = "Game Drawn.<br><strong> Well played!</strong>";
            }
            return {__html: winnerText};
        };

        return (
            <div className="leader-board">
                <p>Leader board</p>
                <div className="display">
                    <strong>Wins:</strong>
                    <div>{getPlayerName("a")} : {getWins("a")}</div>
                    <div>{getPlayerName("b")} : {getWins("b")}</div>
                </div>
                <div className="display">
                    <strong>Draws</strong> : {getDraws()}
                </div>
                <div className="congrats-text" dangerouslySetInnerHTML={winner(this.props.winner)}></div>
            </div>
        );
    }
});

var Grid = React.createClass({
    render: function () {
        var squares = [];
        var winnerBlocks = [];
        var data = this.props.data;
        var nextTurn = data.next_turn;
        var winner = {status: data.game_status.state};
        if (data.game_status.state === "won") {
            winnerBlocks = data.game_status.winner_blocks;
            winner = data.next_turn === "a" ? {player: "b", status: "won"} : {player: "a", status: "won"};
            nextTurn = "";
        }

        if (data.game_status.state === "draw") {
            nextTurn = "";
        }

        jQuery.each(data.grid, function (i, row) {
            jQuery.each(row, function (j, item) {
                var winnerBlock = false;
                if (winnerBlocks.length === 3) {
                    var k;
                    for (k = 0; k < 3; k++) {
                        if (winnerBlocks[k][0] === i && winnerBlocks[k][1] === j) {
                            winnerBlock = true;
                            break;
                        }
                    }
                }
                squares.push(
                    <Square key={(i * 10) + j} row={i} column={j} value={item}
                            winnerBlock={winnerBlock} gameStatus={data.game_status.state}/>
                );
            });
        });
        var player1Name = getPlayerName("a") + " (X)";
        var player2Name = getPlayerName("b") + " (O)";
        return (
            <div>
                <LeaderBoard winner={winner}/>
                <div className="grid">
                    {squares}
                </div>
                <div className="players">
                    <p>Current Turn:</p>
                    <Player name={player1Name} id="a" next_turn={nextTurn}/>
                    <Player name={player2Name} id="b" next_turn={nextTurn}/>
                </div>
            </div>
        );
    }
});

var Game = React.createClass({
    getInitialState: function () {
        return {data: {grid: [], game_status: {}}};
    },
    componentDidMount: function () {
        jQuery.ajax({
            url: this.props.url,
            dataType: "json",
            cache: false,
            success: function (data) {
                this.setState({data: data});
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    render: function () {
        return (
            <Grid data={this.state.data}/>
        );
    }
});

var url = "/" + window.Globals.GameID + ".json";
ReactDOM.render(<Game url={url}/>, document.getElementById("content"));
