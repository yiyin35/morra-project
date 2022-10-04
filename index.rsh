// automation done - timeout done - loop done - interaction done
// working on web ui
'reach 0.1';

const [ isFingers, ZERO, ONE, TWO, THREE, FOUR, FIVE ] = makeEnum(6);
const [ isGuess, ZEROG, ONEG, TWOG, THREEG, FOURG, FIVEG, SIXG, SEVENG, EIGHTG, NINEG, TENG ] = makeEnum(11);
const [ isOutcome, B_WINS, DRAW, A_WINS ] = makeEnum(3);

const winner = (fingersA, fingersB, guessA, guessB) => {
  if(guessA == guessB) {
    const myOutcome = DRAW;
    return myOutcome;
  } else {
    if(((fingersA + fingersB) == guessA)) {
      const myOutcome = A_WINS;
      return myOutcome;
    } else {
      if(((fingersA + fingersB) == guessB)) {
        const myOutcome = B_WINS;
        return myOutcome;
      } else {
        const myOutcome = DRAW;
        return myOutcome;
      }
    }
  }
};

assert(winner(ZERO,TWO,ZEROG,TWOG) == B_WINS);
assert(winner(TWO,ZERO,TWOG,ZEROG) == A_WINS);
assert(winner(ZERO,ONE,ZEROG,TWOG) == DRAW);
assert(winner(ONE,ONE,ONEG,ONEG) == DRAW);

forall(UInt, fingersA =>
  forall(UInt, fingersB =>
    forall(UInt, guessA =>
      forall(UInt, guessB =>
        assert(isOutcome(winner(fingersA, fingersB, guessA, guessB)))))));

forall(UInt, (fingerA) =>
  forall(UInt, (fingerB) =>       
    forall(UInt, (guess) =>
      assert(winner(fingerA, fingerB, guess, guess) == DRAW))));

const Player = {
  ...hasRandom,
  getFingers: Fun([], UInt),
  getGuess: Fun([UInt], UInt),
  seeAnswer: Fun([UInt], Null),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null)
};

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    // Specify Alice's interact interface here
    ...Player,
    wager: UInt,
    deadline: UInt
  });
  const Bob = Participant('Bob', {
    // Specify Bob's interact interface here
    ...Player,
    acceptWager: Fun([UInt], Null),
  });
  init();

  const informTimeout = () => {
    each([Alice, Bob], () => {
      interact.informTimeout();
    });
  };

  // The first one to publish deploys the contract
  Alice.only(() => {
    const amount = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
  });
  Alice.publish(amount, deadline)
       .pay(amount);
  commit();

  Bob.only(() => {
    interact.acceptWager(amount);
  });
  Bob.pay(amount)
     .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

  var outcome = DRAW;
  invariant(balance() == 2 * amount && isOutcome(outcome));
  
  while(outcome == DRAW) {
    commit();

    Alice.only(() => {
      const _fingersA = interact.getFingers();
      const _guessA = interact.getGuess(_fingersA);
      //interact.log(_fingersA);
      const [ _commitAlice, _saltAlice ] = makeCommitment(interact, _fingersA);
      const commitAlice = declassify(_commitAlice);
      const [_guessCommitA, _guessSaltA] = makeCommitment(interact, _guessA);
      const guessCommitA = declassify(_guessCommitA);
    });
    Alice.publish(commitAlice)
       .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
    commit();    

    Alice.publish(guessCommitA)
        .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
    commit();

    unknowable(Bob, Alice(_fingersA, _saltAlice));
    unknowable(Bob, Alice(_guessA, _guessSaltA));

    Bob.only(() => {
      const _fingersB = interact.getFingers();
      const _guessB = interact.getGuess(_fingersB);
      const fingersB = declassify(_fingersB);
      const guessB = declassify(_guessB);
    });
    // The second one to publish always attaches
    
    Bob.publish(fingersB)
        .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
    commit();
    Bob.publish(guessB)
      .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
      commit();
    

    Alice.only(() => {
      const [saltAlice, fingersA] = declassify([_saltAlice, _fingersA]); 
      const [guessSaltA, guessA] = declassify([_guessSaltA, _guessA]);
    });
    Alice.publish(saltAlice, fingersA)
        .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
    checkCommitment(commitAlice, saltAlice, fingersA);
    commit();

    Alice.publish(guessSaltA, guessA)
        .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
    checkCommitment(guessCommitA, guessSaltA, guessA);
    commit();

    Alice.only(() => {        
      const answer = fingersA + fingersB;
      interact.seeAnswer(answer);
    });

    Alice.publish(answer)
        .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

    outcome = winner(fingersA, fingersB, guessA, guessB);
    continue;
  }

  // write your program here
  assert(outcome == A_WINS || outcome == B_WINS);

  transfer(2*amount).to(outcome == A_WINS ? Alice : Bob);
  commit();

  each([Alice, Bob], () => {
      interact.seeOutcome(outcome)
  });
  
  exit();
});
