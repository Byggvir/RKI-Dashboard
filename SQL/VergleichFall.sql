use RKI;

delimiter //

drop procedure if exists FaelleBundesland //

create procedure FaelleBundesland ()
begin

set @i:=0;

select 
    @i:=@i+1 as Rang
    , Bundesland
    , AnzahlFall as Anzahl
    , Bevoelkerung
    , InfectionRatio
from (
select 
      A.IdBundesland
    , B.Bundesland as Bundesland
    , Altersgruppe
    , sum(A.AnzahlFall) as Anzahlfall
    , D.Anzahl as Bevoelkerung
    , sum(A.AnzahlFall)/D.Anzahl as InfectionRatio
from Faelle as A 
join Bundesland as B 
on 
    A.IdBundesland = B.IdBundesland 
join
    ( select 
          IdBundesland
        , sum(Anzahl) as Anzahl
      from DESTATIS.DT124110013
      group by IdBundesland
    )
    as D 
on 
    A.IdBundesland = D.IdBundesland 
group by 
      A.IdBundesland
order by AnzahlFall desc
) as R
order by
    InfectionRatio desc
;

end
//

drop procedure if exists FaelleBundeslandAlter //

create procedure FaelleBundeslandAlter ( AG CHAR(20) )
begin

set @i:=0;

select 
    @i:=@i+1 as Rang
    , Bundesland
    , AnzahlFall as Anzahl
    , Bevoelkerung
from (
select 
      A.IdBundesland
    , B.Bundesland as Bundesland
    , Altersgruppe
    , sum(A.AnzahlFall) as AnzahlFall
    , D.Anzahl as Bevoelkerung
from Faelle as A 
join Bundesland as B 
on 
    A.IdBundesland = B.IdBundesland 
join
    ( select 
          IdBundesland
        , sum(Anzahl) as Anzahl
      from DESTATIS.DT124110013
      group by IdBundesland
    )
    as D 
on 
    A.IdBundesland = D.IdBundesland 
 
where Altersgruppe = AG
group by 
      A.IdBundesland
    , A.Altersgruppe 
order by AnzahlFall desc
) as R
;

end
//

drop procedure if exists InfectionsBundesland //

create procedure InfectionsBundesland ( AG CHAR(20) )
begin

set @i:=0;

set @TMP:= REGEXP_REPLACE(AG ,'A80\\+','A80-A99');

set @L:= REGEXP_REPLACE(@TMP ,'A([0-9]{2})[-].*','\\1');
set @U:= REGEXP_REPLACE(@TMP ,'A[0-9]{2}-A([0-9]{2})','\\1');

select 
    @i:=@i+1 as Rang
    , R.Bundesland
    , R.Anzahl
    , R.Bevoelkerung
    , R.IncectionRatio
from (
select 
      A.IdBundesland
    , B.Bundesland
    , Altersgruppe
    , sum(AnzahlFall) as Anzahl
    , C.Anzahl as Bevoelkerung
    , sum(AnzahlFall)/C.Anzahl*100000 as InfectionRatio
from Faelle as A 
join Bundesland as B 
on 
    A.IdBundesland = B.IdBundesland
join
    ( select 
          IdBundesland
        , sum(Anzahl) as Anzahl
      from DESTATIS.DT124110013
      where 
        Altersgruppe >= @L 
        and Altersgruppe <= @U
      group by IdBundesland
    )
    as C 
on 
    A.IdBundesland = C.IdBundesland 
where 
    A.Altersgruppe = AG
group by IdBundesland,Altersgruppe 
order by InfectionRatio desc
) as R
;

end
//

drop procedure if exists InfectionsBundeslandStdBev //

create procedure InfectionsBundeslandStdBev ()
begin

set @bev := (Select sum(Anzahl) from DESTATIS.StdBev6);

set @i:=0;

select 
    @i:=@i+1 as Rang
    , Z.Bundesland
    , round(Z.SAnzahl / @bev *100000,4) as InfectionRatio
from (
select 
      R.IdBundesland
    , R.Bundesland
    , sum(R.SInfections) as SAnzahl
from (
select 
      A.IdBundesland
    , L.Bundesland
    , A.Geschlecht
    , A.Altersgruppe
    , sum(AnzahlFall) as Anzahl
    , sum(AnzahlFall)/B.Anzahl*S.Anzahl as SInfections
from Faelle as A 
join Bundesland as L
on 
    A.IdBundesland = L.IdBundesland

join DESTATIS.StdBev6 as S 
on 
    A.Altersgruppe = S.Altersgruppe 
    and A.Geschlecht = S.Geschlecht 

join DESTATIS.StdBev6BL as B
on 
    A.IdBundesland = B.IdBundesland
    and A.Geschlecht = B.Geschlecht 
    and A.Altersgruppe = B.Altersgruppe 

group by 
    A.IdBundesland
    , A.Geschlecht
    , A.Altersgruppe 
) as R
group by 
    R.IdBundesland
--    , R.Geschlecht
order by SAnzahl desc
) as Z
;

end
//

delimiter ; 
