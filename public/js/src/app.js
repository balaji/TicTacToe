"use strict";

var React = require("react");
var ReactDOM = require("react-dom");
var jQuery = require("jquery");

var Square = React.createClass({
    playGame: function () {
        if (this.props.value !== "-") {
            return;
        }
        var url = "/" + window.Globals.GameID + "/mark.json";
        jQuery.ajax({
            url: url,
            dataType: 'json',
            cache: false,
            method: 'POST',
            data: {"row": this.props.row, "column": this.props.column},
            success: function (data) {
                //Re-render parent with updated data.
                ReactDOM.render(<Grid data={data}/>, document.getElementById('content'));
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(url, status, err.toString());
            }.bind(this)
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

var Grid = React.createClass({
    render: function () {
        var squares = [];
        var winnerBlocks = [];
        var data = this.props.data;
        console.log(data);
        if (data.game_status.state === "won") {
            winnerBlocks = data.game_status.winner_blocks;
        }
        jQuery.each(data.grid, function (i, row) {
            jQuery.each(row, function (j, item) {

                var winnerBlock = false;
                if (winnerBlocks.length === 3) {
                    var k;
                    for (k = 0; k < 3; k++) {
                        if (winnerBlocks[k][0] == i && winnerBlocks[k][1] == j) {
                            winnerBlock = true;
                            break;
                        }
                    }
                }

                squares.push(<Square key={( i * 10) + j} row={i} column={j} value={item} winnerBlock={winnerBlock}/>);
            });
        });
        return (
            <div className="grid">
                {squares}
            </div>
        );
    }
});

var Game = React.createClass({
    getInitialState: function () {
        return {data: {grid: [], game_status: {}}};
    },
    loadData: function () {
        jQuery.ajax({
            url: this.props.url,
            dataType: 'json',
            cache: false,
            success: function (data) {
                this.setState({data: data});
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    componentDidMount: function () {
        this.loadData();
    },
    render: function () {
        return (
            <Grid data={this.state.data}/>
        );
    }
});

var url = "/" + window.Globals.GameID + ".json";
ReactDOM.render(<Game url={url}/>, document.getElementById('content'));
