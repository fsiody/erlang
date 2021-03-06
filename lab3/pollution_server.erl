%%%-------------------------------------------------------------------
%%% @author helen
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Apr 2019 1:00
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("helen").

%% API
-export([start/0,stop/0,addStation/2,addValue/4,removeValue/3,getOneValue/3,
  getStationMean/2,getDailyMean/2,getMovingMean/2,crash/0 ]).

crash()->1/0.

start()->
  io:format("started ~n"),
  register(psver,spawn(fun init/0)).
stop()-> psver ! stop.
init()->
  Monitor=pollution:createMonitor(),
  loop(Monitor).
getM()->
  receive
    ok->ok;
    {ok,M}->io:format("   ----->   "),M;
    {error,M}->M
  end.

addStation(StationName,Coord)-> psver ! {self(),addStn, StationName, Coord},getM().
addValue(Id, Time, DataName, Data)-> psver ! {self(),addVl, Id, Time, DataName, Data},getM().
removeValue(Id, Time, DataName)-> psver ! {self(),removeVl, Id, Time, DataName},getM().
getOneValue(Id, Time, DataName)-> psver ! {self(),getOneVl, Id, Time, DataName},getM().
getStationMean(Id, DataName)-> psver ! {self(),getStnMean, Id, DataName},getM().
getDailyMean(Date, DataName)->psver ! {self(),getDlMean, Date, DataName},getM().
getMovingMean(Id,DataName)->psver ! {self(),getMvMean, Id, DataName},getM().




loop(Monitor)->
  receive
    ok->ok;
    stop ->{ok,"Server has been stoped"};
    {Pid, addStn, StationName, Coord} ->
      Res=pollution:addStation(StationName, Coord, Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess} , loop(Monitor);
        _-> Pid ! {ok,Res}, loop(Res)
      end;

    {Pid, addVl, Id, Time, DataName, Data} ->
      Res=pollution:addValue(Id, Time, DataName, Data, Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess} , loop(Monitor);
        _-> Pid ! {ok,Res}, loop(Res)
      end;

    {Pid, removeVl, Id, Time, DataName} ->
      Res=pollution:removeValue(Id, Time, DataName,Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess} , loop(Monitor);
        _-> Pid ! {ok,Res}, loop(Res)
      end;

    {Pid, getOneVl, Id, Time, DataName} ->
      Res=pollution:getOneValue(Id,Time,DataName,Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess};
        _-> Pid ! {ok, Res}
      end,
      loop(Monitor);

    {Pid, getStnMean, Id, DataName} ->
      Res=pollution:getStationMean(Id,DataName,Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess};
        _-> Pid ! {ok, Res}
      end,
      loop(Monitor);

    {Pid, getDlMean, Date, DataName} ->
      Res=pollution:getDailyMean(Date, DataName, Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess};
        _-> Pid ! {ok, Res}
      end,
      loop(Monitor);
    {Pid, getMvMean, Id, DataName} ->
      Res=pollution:getMovingMean(Id, DataName, Monitor),
      case Res of
        {error,Mess}->Pid ! {error,Mess};
        _-> Pid ! {ok, Res}
      end,
      loop(Monitor)
  end.





