%%% ----------------------------------------------------------------------------
%%% @author Duncan Paul Attard
%%%
%%% @doc Module description (becomes module heading).
%%%
%%% @end
%%% 
%%% Copyright (c) 2022, Duncan Paul Attard <duncanatt@gmail.com>
%%%
%%% This program is free software: you can redistribute it and/or modify it 
%%% under the terms of the GNU General Public License as published by the Free 
%%% Software Foundation, either version 3 of the License, or (at your option) 
%%% any later version.
%%%
%%% This program is distributed in the hope that it will be useful, but WITHOUT 
%%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
%%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
%%% more details.
%%%
%%% You should have received a copy of the GNU General Public License along with 
%%% this program. If not, see <https://www.gnu.org/licenses/>.
%%% ----------------------------------------------------------------------------
-module(lin_6).
-author("Duncan Paul Attard").

-compile(export_all).

%%% Includes.
-include_lib("stdlib/include/assert.hrl").
-include("log.hrl").

%%% Public API.
-export([]).

%%% Callbacks/Internal.
-export([]).

%%% Types.
-export_type([]).

%%% Implemented behaviors.
%-behavior().


%%% ----------------------------------------------------------------------------
%%% Macro and record definitions.
%%% ----------------------------------------------------------------------------


%%% ----------------------------------------------------------------------------
%%% Type definitions.
%%% ----------------------------------------------------------------------------


%%% ----------------------------------------------------------------------------
%%% Public API.
%%% ----------------------------------------------------------------------------

% Monitor for the property that all actions are unique.
%%max(X.[a,true](max(Y.[b,a=:=b]ff and [b,a=/=b]Y) and X))
m3() ->
  {ok,
    {rec, "max(X. a,true.and(max(Y. (b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes)) and X) + a,not(true).yes)",
      fun X() -> % max(X.
        {chs, "a,true.and(max(Y. (b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes)) and X) + a,not(true).yes",
          {act, "a,true.and(max(Y. (b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes)) and X)",
            fun(A) -> true; (_) -> false end, % true
            fun(A) -> % a
              {'and', "max(Y. (b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes)) and X",
                {rec, "max(Y. (b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes))",
                  fun Y() -> % max(Y.
                    {'and', "(b,a=:=b.no + b,not(a=:=b).yes) and (b,a=/=b.Y + b,not(a=/=b).yes)",
                      {chs, "b,a=:=b.no + b,not(a=:=b).yes",
                        {act, "b,a=:=b.no",
                          fun(B) when A =:= B -> true; (_) -> false end, % a=:=b
                          fun(B) -> % b
                            {no, "no"} % ff
                          end
                        },
                        {act, "b,not(a=:=b).yes",
                          fun(B) when A =:= B -> false; (_) -> true end, % a=/=b
                          fun(_) -> % b
                            {yes, "yes"} % yes
                          end
                        }
                      },
                      {chs, "b,a=/=b.Y + b,not(a=/=b).yes",
                        {act, "b,a=/=b.Y",
                          fun(B) when A =/= B -> true; (_) -> false end, % a=/=b
                          fun(B) -> % [b,a=/=b]
                            {rec, "Y", Y} % Y
                          end
                        },
                        {act, "b,not(a=/=b).yes",
                          fun(B) when A =/= B -> false; (_) -> true end, % b,a=:=b
                          fun(_) -> % b
                            {yes, "yes"} % yes
                          end
                        }
                      }
                    }
                  end
                }, % end max(Y)
                {rec, "X", X} % X
              }
            end
          },
          {act, "a,not(true).yes",
            fun(A) -> false; (_) -> true end, % false
            fun(_) -> % a
              {yes, "yes"} % yes
            end
          }
        }
      end} % end max(X)
  }.


% Monitor for the formula [a,true]ff and [b,true]ff and [c,true]ff.
m2() ->
  {ok,
    {'and', "(({:A},true.no + {:A},not(true).yes) and ({:B},true.no + {:B},not(true).yes)) and ({:C},true.no + {:C},not(true).yes)",
      {'and', "({:A},true.no + {:A},not(true).yes) and ({:B},true.no + {:B},not(true).yes)",
        {chs, "({:A},true.no + {:A},not(true).yes)",
          {act, "{:A},true.no",
            fun(A) -> true; (_) -> false end,
            fun(A) ->
              {no, "no"}
            end
          },
          {act, "{:B},not(true).yes",
            fun(A) -> false; (_) -> true end,
            fun(A) ->
              {yes, "yes"}
            end
          }
        },
        {chs, "({:B},true.no + {:B},not(true).yes)",
          {act, "{:B},true.no",
            fun(B) -> true; (_) -> false end,
            fun(B) ->
              {no, "no"}
            end
          },
          {act, "{:B},not(true).yes",
            fun(B) -> false; (_) -> true end,
            fun(B) ->
              {yes, "yes"}
            end
          }
        }
      },
      {chs, "({:C},true.no + {:C},not(true).yes)",
        {act, "{:C},true.no",
          fun(C) -> true; (_) -> false end,
          fun(C) ->
            {no, "no"}
          end
        },
        {act, "{:C},not(true).yes",
          fun(C) -> false; (_) -> true end,
          fun(C) ->
            {yes, "yes"}
          end
        }
      }
    }
  }.

% Property [a,true]ff and no.
m4() ->
  {ok,
    {'and', "(a,true.no + a,not(true).yes) and no",
      {chs, "(a,true.no + a,not(true).yes)",
        {act, "a,true.no",
          fun(A) -> true; (_) -> false end,
          fun(A) ->
            {no, "no"}
          end
        },
        {act, "a,not(true).yes",
          fun(A) -> false; (_) -> true end,
          fun(_) ->
            {yes, "yes"}
          end
        }
      },
      {no, "no"}
    }
  }.


% In no verbose mode.
%%{act,
%%  {env,[]},
%%  cond,
%%  body
%%}

% In verbose mode.
%%{act,
%%  {env,[{str, "monitor string representation"}, {var, "variable name"}]},
%%  cond,
%%  body
%%}

%%{con,
%%  left,
%%  right
%%}

%%{dis,
%%  left,
%%  right
%%}

%%{rec,
%%  right
%%}


% Rules.

%%to_string({'and', _, M, N}) ->
%%  to_string(M);
%%
%%to_string({chs, _, M, N}) ->
%%  to_string(M);
%%
%%to_string({act, _, C, M}) ->
%%  erlang:fun_info(C),
%%  erlang:fun_to_list(C).

%%TODO: Test with m3 tomorrow!


% Return result from derive: the action that was used, tau or act.

% Derivation strategy.
derive_tau(R = {'and', _S, {yes, _}, M}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mConYL: ~s.", [fmt_id(Id), _S]),

  % Axiom mConYL.
  {true, {{Id, mConYL, tau, _S}, M}};

derive_tau(R = {'and', _S, M, {yes, _}}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mConYR: ~s.", [fmt_id(Id), _S]),

  % Axiom mConYR.
  {true, {{Id, mConYR, tau, _S}, M}};

derive_tau(R = {'and', _S, No = {no, _}, _}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mConNL: ~s.", [fmt_id(Id), _S]),

  % Axiom mConNL.
  {true, {{Id, mConNL, tau, _S}, No}};

derive_tau(R = {'and', _S, _, No = {no, _}}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mConNR: ~s.", [fmt_id(Id), _S]),

  % Axiom mConNR.
  {true, {{Id, mConNR, tau, _S}, No}};

derive_tau(R = {'or', _S, Yes = {yes, _}, _}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mDisYL: ~s.", [fmt_id(Id), _S]),

  % Axiom mDisYL.
  {true, {{Id, mDisYL, tau, _S}, Yes}};

derive_tau(R = {'or', _S, _, Yes = {yes, _}}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mDisYR: ~s.", [fmt_id(Id), _S]),

  % Axiom mDisYR.
  {true, {{Id, mDisYR, tau, _S}, Yes}};

derive_tau(R = {'or', _S, {no, _}, M}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mDisNL: ~s.", [fmt_id(Id), _S]),

  % Axiom mDisNL.
  {true, {{Id, mDisNL, tau, _S}, M}};

derive_tau(R = {'or', _S, M, {no, _}}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mDisNR: ~s.", [fmt_id(Id), _S]),

  % Axiom mDisNR.
  {true, {{Id, mDisNR, tau, _S}, M}};

derive_tau(R = {rec, _S, M}, Id) ->
  ?DEBUG(":: (~s) Reducing using axiom mRec: ~s.", [fmt_id(Id), _S]),

  % Axiom mRec.
  M_ = M(),
  {true, {{Id, mRec, tau, _S}, M_}};

derive_tau(R = {Op, _S, M, N}, Id) when Op =:= 'and'; Op =:= 'or' ->

  ?DEBUG(":: (~s) Trying to reduce using rule mTauL: ~s.", [fmt_id(Id), _S]),
  case derive_tau(M, new_id(Id)) of
    false ->
      ?DEBUG(":: (~s) Trying to reduce using rule mTauR: ~s.", [fmt_id(Id), _S]),
      case derive_tau(N, new_id(Id)) of
        false ->
          false;
        {true, {PdN, N_}} ->
          {true, {{Id, mTauR, tau, _S, {pd, PdN}}, {Op, element(2, M) ++ " " ++ atom_to_list(Op) ++ " " ++ element(2, N_), M, N_}}}
      end;
    {true, {PdM, M_}} ->
      {true, {{Id, mTauL, tau, _S, {pd, PdM}}, {Op, element(2, M_) ++ " " ++ atom_to_list(Op) ++ " " ++ element(2, N), M_, N}}}
  end;

derive_tau(_, _) ->
  false.


derive_act(Act, V_ = {V, _S}, Id) when V =:= yes; V =:= no ->
  ?assertNot(Act =:= tau),
  ?DEBUG(":: (~s) Reducing using axiom mVrd: ~s.", [fmt_id(Id), _S]),

  % Axiom mVrd.
  {{Id, mVrd, Act, _S}, V_};

derive_act(Act, R = {act, _S, C, M}, Id) ->
  ?assertNot(Act =:= tau),
  ?assert(C(Act)),
  ?assert(is_function(M, 1)),
  ?DEBUG(":: (~s) Reducing using rule mAct: ~s.", [fmt_id(Id), _S]),

  % Axiom mAct.
  M_ = M(Act),
%%  {{Id, mAct, Act, _S}, M_};
  {{Id, mAct, Act, _S}, M_};

derive_act(Act, R = {chs, _S, M, N}, Id) ->
  ?assert(is_tuple(M) andalso element(1, M) =:= act),
  ?assert(is_tuple(N) andalso element(1, N) =:= act),

  case {can_act(Act, M), can_act(Act, N)} of
    {true, false} ->
      ?DEBUG(":: (~s) Reducing using rule mChsL: ~s.", [fmt_id(Id), _S]),

      % Rule mChsL.
      {PdM, M_} = derive_act(Act, M, new_id(Id)),
      {{Id, mChsL, Act, _S, {pd, PdM}}, M_};

    {false, true} ->
      ?DEBUG(":: (~s) Reducing using rule mChsR: ~s.", [fmt_id(Id), _S]),

      % Rule mChsR.
      {PdN, N_} = derive_act(Act, N, new_id(Id)),
      {{Id, mChsR, Act, _S, {pd, PdN}}, N_}
  end;



derive_act(Act, R = {Op, _S, M, N}, Id) when Op =:= 'and'; Op =:= 'or' ->
  ?assertNot(Act =:= tau),
  ?DEBUG(":: (~s) Reducing using rule mPar: ~s.", [fmt_id(Id), _S]),

  {{PdM, M_}, {PdN, N_}} = {derive_act(Act, M, new_id(Id)), derive_act(Act, N, inc_id(new_id(Id)))},
  {{Id, mPar, Act, _S, {pd, PdM}, {pd, PdN}}, {Op, element(2, M_) ++ " " ++ atom_to_list(Op) ++ " " ++ element(2, N_), M_, N_}}.


can_act(Act, {act, _S, C, _M}) ->
  ?assert(is_function(_M, 1)),
  C(Act).


new_id(Id) when is_list(Id) ->
  [1 | Id].

inc_id([Idx | Idxs]) ->
  [Idx + 1 | Idxs].

fmt_id(Id = [_ | _]) ->
%%  tl(lists:flatten(
%%    lists:foldl(fun(Idx, Id) -> [[".", integer_to_list(Idx)] | Id] end, [], Id)
%%  )).
  tl(lists:foldl(fun(Idx, Id) -> [$., integer_to_list(Idx) | Id] end, [], Id)).
%%  {_, IoList} = lists:foldl(
%%    fun(Idx, {1, IoList}) -> {1, [integer_to_list(Idx) | IoList]};
%%      (Idx, {I, IoList}) -> {I - 1, [$., integer_to_list(Idx) | IoList]}
%%    end,
%%    {length(Id), []}, Id),
%%  IoList.


fmt_pdlst(PdList) ->
  lists:foldl(
    fun(Pd, {I, IoList}) ->
      {I - 1, [[io_lib:format("~nDerivation ~w:~n", [I]), fmt_pd(Pd)] | IoList]}
    end,
    {length(PdList), []}, PdList
  ).

show_pdlst(PdList) ->
  {_, IoList} = fmt_pdlst(PdList),
  io:format("~s~n", [IoList]).



fmt_pd({Id, Rule, Act, S}) ->
  io_lib:format("~*s (~s) axiom ~s on '~w': ~s ~n", [length(Id) + 2, "->", fmt_id(Id), Rule, Act, S]);


fmt_pd({Id, Rule, Act, S, {pd, PdM}}) ->
  PdMFmt = fmt_pd(PdM),
  [io_lib:format("~*s (~s) rule ~s on '~w': ~s using premise~n", [length(Id) + 2, "->", fmt_id(Id), Rule, Act, S]) | PdMFmt];


fmt_pd({Id, Rule, Act, S, {pd, PdM}, {pd, PdN}}) ->
  {PdMFmt, PdNFmt} = {fmt_pd(PdM), fmt_pd(PdN)},
  [[io_lib:format("~*s (~s) rule ~s on '~w': ~s using premises~n", [length(Id) + 2, "->", fmt_id(Id), Rule, Act, S]) | PdMFmt] | PdNFmt].


format_ph(IoList, Name, Value) ->
  Pat = [${, $:, atom_to_list(Name), $}],
  case re:run(IoList, Pat, [global]) of
    nomatch ->
      IoList;
    {match, Matches} ->
      Format = re:replace(IoList, Pat, "~w", [global, {return, list}]),
      io_lib:format(Format, lists:duplicate(length(Matches), Value))
  end.


%%re:run("{:a}, when {:a}=:= {b}", ["{:a}"], [global]).
%%re:replace(IoData, "{:a}", "~w", [global, {return, list}]).

% Can tau means try to derive using tau. So I call derive(tau, M). What is the
% return value I should expect? {tau, X} or false?


% Next, implement whether it can tau left or right.
% We do this checking, since we dont want to unfold the monitor and consume
% actions, remembering that monitors are forward only, and we cannot try actions
% and then backtrack when we discover that we cannot use them. We could have a
% one action lookahead, but I think that it might complicate stuff.


% For try tau to work, I need to try to derive the rules.
% I can process a tau if:
% 1) try_tau left
% 2) try tau right
% 3) If both fail, then mPar


% Would it make sense to split the derivation in functions like: derive_tau, derive_act?
% Yes.

reduce_tau(M, PdLst) ->
  ?TRACE("[ Starting a new derivation for monitor on action 'tau' ]"),

  case derive_tau(M, new_id([])) of
    false ->

      % No more tau reductions.
      {PdLst, M};
    {true, {PdM, M_}} ->

      % Monitor state reduced by one tau transition. Attempt to reduce further.
      reduce_tau(M_, [PdM | PdLst])
  end.

% Assumes that the monitor is already in a ready state.
analyze(Act, M, PdLst) ->
  ?TRACE("[ Starting a new derivation for monitor on action '~p' ]", [Act]),

  % Analyze action.
  {PdM, M_} = derive_act(Act, M, new_id([])),

  % Check whether the residual monitor state can be reduced further using tau
  % transitions. This ensures that the monitor is always left in a state where
  % it is ready to analyse the next action.
  reduce_tau(M_, [PdM | PdLst]).




can_tau({yes, _S}) ->
  ?TRACE("Checking ~s.", [_S]),
  false;
can_tau({no, _S}) ->
  ?TRACE("Checking ~s.", [_S]),
  false;
can_tau({chs, _S, _, _}) ->
  % The case for act is subsumed by this case.
  ?TRACE("Checking ~s.", [_S]),
  false;

can_tau({rec, _S, _}) ->
  ?TRACE("Checking ~s.", [_S]),
  true;
can_tau({'and', _S, {yes, _}, _}) ->
  ?TRACE("Checking ~s.", [_S]),
  true;
can_tau({'and', _S, {'no', _}, _}) ->
  ?TRACE("Checking ~s.", [_S]),
  true;
can_tau({'or', _S, {'yes', _}, _}) ->
  ?TRACE("Checking ~s.", [_S]),
  true;
can_tau({'or', _S, {'no', _}, _}) ->
  ?TRACE("Checking ~s.", [_S]),
  true;
can_tau({'and', _S, M, N}) ->
  ?TRACE("Checking ~s.", [_S]),
  Ret = can_tau(M) orelse can_tau(N),
  ?TRACE("Got ~s after checking ~s.", [Ret, _S]),
  Ret;

can_tau({'or', _S, M, N}) ->
  ?TRACE("Checking ~s.", [_S]),
  Ret = can_tau(M) orelse can_tau(N),
  ?TRACE("Got ~s after checking ~s.", [Ret, _S]),
  Ret.


pp_erlang(Erl) ->
  {ok, Tokens, _EndLine} = erl_scan:string(Erl),
  {ok, [AbsForm]} = erl_parse:parse_exprs(Tokens),
  io:format("~p~n", [AbsForm]),
  Clauses = erl_syntax:fun_expr_clauses(AbsForm),
  io:format("Clauses are: ~p~n", [Clauses]),
  Guard = erl_syntax:clause_guard(hd(Clauses)),
  io:format("Guard is: ~p~n", [Guard]).
%%  erl_pp:expr(AbsForm). % This prints any expression.

print_fun_guard(ErlFunStr) ->
  {ok, Tokens, _EndLine} = erl_scan:string(ErlFunStr),
  {ok, [AbsForm]} = erl_parse:parse_exprs(Tokens),
  Clauses = erl_syntax:fun_expr_clauses(AbsForm),
  {clause, _, _, GuardGood, _} = hd(Clauses),
  io:format("The good guard: ~p~n", [GuardGood]),
  GuardBad = erl_syntax:clause_guard(hd(Clauses)), % Bad guard is not printable by erl_pp:guard/1.
  io:format("The bad guard: ~p~n", [erl_syntax:revert(GuardBad)]),
  lists:flatten(erl_pp:guard(GuardGood)).


% TODO: What if we have no + yes synthesised from ff. This cannot happen.

% Tests:
% M0 = {chs, "", {no, ""}, {yes, ""}}. % This cannot be a monitor that I synthesize.
% M0 = {'and', "no and yes", {no, "no"}, {yes, "yes"}}.
% M1 = {'and', "(((no and yes) and yes) and yes) and yes", {'and', "((no and yes) and yes) and yes", {'and', "(no and yes) and yes", {'and', "no and yes", {no, "no"}, {yes, "yes"}}, {yes, "yes"}}, {yes, "yes"}}, {yes, "yes"}}.
% TODO: I cannot have a monitor when ff just synthesizes ff + tt M2 = {'and', "(((no + yes) and yes) and yes) and yes", {'and', "((no + yes) and yes) and yes", {'and', "(no + yes) and yes", {chs, "no + yes", {no, "no"}, {yes, "yes"}}, {yes, "yes"}}, {yes, "yes"}}, {yes, "yes"}}.
% M3 = {'and', "", {'and', "", {'and', "", {chs, "", {no, ""}, {yes, ""}}, {chs, "", {no, ""}, {yes, ""}}}, {chs, "", {no, ""}, {yes, ""}}}, {chs, "", {no, ""}, {yes, ""}}}
% M4 = {'and', "", {'and', "", {chs, "", {no, ""}, {yes, ""}}, {chs, "", {no, ""}, {yes, ""}}}, {'and', "", {chs, "", {no, ""}, {yes, ""}}, {chs, "", {no, ""}, {yes, ""}}}}


%%% ----------------------------------------------------------------------------
%%% Private helper functions.
%%% ----------------------------------------------------------------------------