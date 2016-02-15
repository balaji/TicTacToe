"use strict";

var React = require("react");
var ReactDOM = require("react-dom");
var jQuery = require("jquery");
var localStore = require("./localStore.js");

/**
 * React component for the individual square in a Tic Tac Toe game board.
 * It has an onClick method that will update the state of the square by calling the backend.
 */
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
                    localStore.updateWins(data.next_turn === "a" ? "b" : "a");
                }
                if (data.game_status.state === "draw") {
                    localStore.updateDraws();
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

/**
 * React component for the Player section.
 * It displays the Player name, their Tic Tac Toe symbol and
 * allows editing the player name.
 */
var Player = React.createClass({
    changeName: function () {
        var newPlayerName = window.prompt("Enter new name", localStore.getPlayerName(this.props.id));
        if (newPlayerName !== null) {
            localStore.updatePlayerName(this.props.id, newPlayerName);
            ReactDOM.render(<Grid data={this.props.data}/>, document.getElementById("content"));
        }
    },
    render: function () {
        var className = "player";
        if (this.props.id === this.props.next_turn) {
            className += " active";
        }
        return (
            <div>
                <div className={className}>{this.props.name}</div>
                <a href="#" onClick={this.changeName}>change</a>
            </div>
        );
    }
});

/**
 * React component to display the Leader board for a given game session.
 */
var LeaderBoard = React.createClass({
    render: function () {
        var winner = function (data) {
            var winnerText = "&nbsp;";
            if (data.status === "won") {
                winnerText = "Game Won. Congratulations!!! <br><strong>" + localStore.getPlayerName(data.player) + "</strong>";
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
                    <div>{localStore.getPlayerName("a")} : {localStore.getWins("a")}</div>
                    <div>{localStore.getPlayerName("b")} : {localStore.getWins("b")}</div>
                </div>
                <div className="display">
                    <strong>Draws</strong> : {localStore.getDraws()}
                </div>
                <div className="congrats-text" dangerouslySetInnerHTML={winner(this.props.winner)}></div>
            </div>
        );
    }
});

/**
 * React component that displays the current state of the game.
 * This is the root component.
 */
var Grid = React.createClass({
    render: function () {
        var squares = [];
        var winnerBlocks = [];
        var data = this.props.data;
        // If there is an error in loading the state of the game,
        // the game board is not shown.
        if (data === "error") {
            return (
                <p>Unexpected error.</p>
            );
        }
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
                // winner blocks are used to display the winning combination if the
                // game is won. The code below checks if a given square
                // belongs to the winning block or not.
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
        var player1Name = localStore.getPlayerName("a") + " (X)";
        var player2Name = localStore.getPlayerName("b") + " (O)";
        return (
            <div>
                <LeaderBoard winner={winner}/>
                <div className="grid">
                    {squares}
                </div>
                <div className="players">
                    <p>Current Turn:</p>
                    <Player name={player1Name} id="a" next_turn={nextTurn} data={data}/>
                    <Player name={player2Name} id="b" next_turn={nextTurn} data={data}/>
                </div>
            </div>
        );
    }
});

/**
 * React component that is used to initialize the Grid for the first time
 * when the page is loaded. It makes a backend call to get the game status.
 */
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
                this.setState({data: "error"});
            }.bind(this)
        });
    },
    render: function () {
        return (
            <Grid data={this.state.data}/>
        );
    }
});

var url = "/" + window.Globals.GameID;
ReactDOM.render(<Game url={url}/>, document.getElementById("content"));
