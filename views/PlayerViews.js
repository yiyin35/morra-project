import React from 'react';

const exports = {};

// Player views must be extended.
// It does not have its own Wrapper view.

exports.GetFingers = class extends React.Component {
  render() {
    const {parent, playable, fingers} = this.props;
    return (
      <div>
        {fingers ? 'It was a draw! Pick again.' : ''}
        <br />
        {!playable ? 'Please wait...' : ''}
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(0)}
        >0</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(1)}
        >1</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(2)}
        >2</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(3)}
        >3</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(4)}
        >4</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(5)}
        >5</button>
      </div>
    );
  }
}

exports.GetGuess = class extends React.Component {
  render() {
    const {parent, playable, guess} = this.props;
    return (
      <div>
        {guess ? 'It was a draw! Pick again.' : ''}
        <br />
        {!playable ? 'Please wait...' : ''}
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(0)}
        >0</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(1)}
        >1</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(2)}
        >2</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(3)}
        >3</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(4)}
        >4</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(5)}
        >5</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(6)}
        >6</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(7)}
        >7</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(8)}
        >8</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(9)}
        >9</button>
        <button
          disabled={!playable}
          onClick={() => parent.playFingers(10)}
        >10</button>
      </div>
    );
  }
}

exports.WaitingForResults = class extends React.Component {
  render() {
    return (
      <div>
        Waiting for results...
      </div>
    );
  }
}

exports.Done = class extends React.Component {
  render() {
    const {outcome} = this.props;
    return (
      <div>
        Thank you for playing. The outcome of this game was:
        <br />{outcome || 'Unknown'}
      </div>
    );
  }
}

exports.Timeout = class extends React.Component {
  render() {
    return (
      <div>
        There's been a timeout. (Someone took too long.)
      </div>
    );
  }
}

export default exports;