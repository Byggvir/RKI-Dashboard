use RKI;

delimiter //

drop procedure if exists CFRBundeslandStdBev //

create procedure CFRBundeslandStdBev ()
begin

set @bev := (Select sum(Anzahl) from DESTATIS.StdBev6);

set @i:=0;

select 
    @i:=@i+1 as Rang
    , Z.Bundesland
    , round(Z.Deaths / Z.Cases*100,2) as CFR
from (
select 
      R.IdBundesland
    , R.Bundesland
    , sum(R.SDeaths) as Deaths
    , sum(R.SCases) as Cases
from (
select 
      A.IdBundesland
    , L.Bundesland
    , A.Geschlecht as Geschlecht
    , A.Altersgruppe
    , sum(A.AnzahlFall)/B.Anzahl*S.Anzahl as SCases
    , sum(A.AnzahlTodesfall)/B.Anzahl*S.Anzahl as SDeaths
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

group by A.IdBundesland,A.Geschlecht,A.Altersgruppe 
) as R
group by 
    R.IdBundesland
    -- , R.Geschlecht
) as Z
order by CFR desc
;

end
//

drop procedure if exists CFRBundesland //

create procedure CFRBundesland ()
begin

set @i:=0;

select 
      @i:=@i+1 as Rang
    , Bundesland 
    , CFR 
from ( 
    select 
        B.Bundesland as Bundesland
        , round(sum(AnzahlTodesfall)/sum(AnzahlFall)*100,2) as CFR
    from Faelle as F 
    join Bundesland as B 
    on 
        F.IdBundesland = B.IdBundesland
    group by F.IdBundesland
    ) as O 
order by 
    CFR desc;
end
//

delimiter ;
