:- include('KB.pl').

/*  start searching for a goal situation */
goal(S):-
		/* if S is a variable, ids(S, D) is called to find a goal situation. */ 
        var(S), ids(S,1);
		/* if S is not a variable, goal_test(S) is called back chaining is performed to decide whether this 
		   situation is a valid one or not */
        \+var(S), goal_test(S).

/* preventing the program from running forever as prolog uses DFS to implement backward chaining */
ids(S, D):-
		/* if it exceeds the depth limit, the predicate is called again with an incremented depth 
		   to perform the search again till a goal situation is reached */
        call_with_depth_limit(goal_test(S), D, X), X \= depth_limit_exceeded;
		D1 is D+1, ids(S, D1).

/*  decides whether the situation needed by Neo to reach his goal */
goal_test(S):-
		/* 1) checks if Neo is standing at telephone booth
		   2) checks if Neo's capacity returned to its maximum
		   3) checks if all hostages have been carried and dropped at the telephone booth */
		booth(X, Y),
        capacity(C),
        neo(X, Y, C, [], S).

/*  decides whether a move action is applicable or not */
move_applicability(A,X,Y):-
		/* checks which movement action is applied and decides its applicability according to 
		   Neo's current position */
        (A = right, grid(_,N), Y < N);
        (A = left, Y > 0);
        (A = up, X > 0);
        (A = down, grid(M,_), X < M).

/*  decides whether a carry action is applicable or not */
carry_applicability(X, Y, C, Hostages):-
		/* 1) checks if Neo is standing at some hostage location
		   2) checks if Neo's capacity is greater than 0 so that he can carry this hostage */
        C>0,
        member([X,Y], Hostages).

/*  decides whether a drop action is applicable or not */
drop_applicability(X, Y, C):-
		/* 1) checks if Neo is standing at telephone booth
		   2) checks if Neo is carrying some hostages */
        booth(X, Y),
        capacity(C1),
        C < C1 .

/*  represents the initial state */      
neo(X, Y, C, Hostages, s0):-
		/*  getting all the grid information provided in the knowledge base  */      
        neo_loc(X, Y),
        hostages_loc(Hostages),
        capacity(C).

/*  successor state axiom */
neo(X, Y, C, Hostages, result(A,S)):-
        neo(X1, Y1, C1, Hostages1, S),
        (
		/* if action is right, check right applicability and update Neo's position (y-ccordinate) */
        (A = right, X is X1, Y is Y1+1, C is C1, move_applicability(A,X1,Y1), Hostages = Hostages1);
		/* if action is left, check left applicability and update Neo's position (y-ccordinate) */
        (A = left, X is X1, Y is Y1-1, C is C1, move_applicability(A,X1,Y1), Hostages = Hostages1);
		/* if action is down, check down applicability and update Neo's position (x-ccordinate) */		
        (A = down, X is X1+1, Y is Y1, C is C1, move_applicability(A,X1,Y1), Hostages = Hostages1);
		/* if action is up, check up applicability and update Neo's position (x-ccordinate) */		
        (A = up, X is X1-1, Y is Y1, C is C1, move_applicability(A,X1,Y1), Hostages = Hostages1);
		/* if action is carry, check carry applicability, decrease new capacity by 1 and delete the 
		   carried hostage's position from hostages array */		
		(A = carry, X is X1, Y is Y1, C is C1-1, carry_applicability(X1,Y1,C1, Hostages1), delete(Hostages1,[X,Y],Hostages));
        /* if action is drop, check drop applicability and update Neo's capacity to its maximum */		
		(A = drop, X is X1, Y is Y1, capacity(C), drop_applicability(X1,Y1,C1), Hostages = Hostages1)
        ).
        
        
