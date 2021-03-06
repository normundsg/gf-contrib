resource ResIta = open Prelude in {

-- parameters

param
  Number = Sg | Pl ;
  Gender = Masc | Fem ;
  Case   = Nom | Acc | Dat | Gen | C_in | C_con | C_da ;
  Agr    = Ag Gender Number Person ;
  Aux    = Avere | Essere ;
  Tense  = Pres | Past | Perf | Fut ;
  Mood   = Ind | Con ;
  Person = Per1 | Per2 | Per3 ;

  VForm = 
     VInf 
   | VInfContr                 -- contracted infinitive, "amar"
   | VPres Mood Number Person 
   | VPast Mood Number Person 
   | VFut Number Person 
   | VPart Gender Number ;

  QForm = QDir | QIndir ;

  ClitAgr = CAgrNo | CAgr Agr ;

-- parts of speech

oper
  VP = {
    v : Verb ; 
    clit : Str ; 
    clitAgr : ClitAgr ; 
    obj : Agr => Str
    } ;

  NP = {
    s : Case => {clit,obj : Str ; isClit : Bool} ; 
    a : Agr
    } ; 

-- the preposition word of an abstract case

  prepCase : Case -> Str = \c -> case c of {
    Dat => "a" ;
    Gen => "di" ;
    C_con => "con" ;
    C_in => "in" ;
    C_da => "da" ;
    _ => []
    } ;

-- for predication

-- this is used for PredVP, QuestVP, SlashV2

    predVP : Str -> Agr -> VP -> {s : Mood => Tense => Bool => Str} = \subj,agr,vp ->
      let 
        obj  = vp.obj ! agr ;
        clit = vp.clit ;
        verb : Mood -> Tense => Str = \m -> table {
          Perf => agrV (auxVerb vp.v.aux) m Pres agr ++ agrPart vp.v agr vp.clitAgr ;
          t    => agrV vp.v m t agr
          }
      in {
        s = \\m,t,b => subj ++ neg b ++ clit ++ verb m ! t ++ obj
      } ;

    useV : Verb -> (Agr => Str) -> VP = \v,o -> {
      v = v ; 
      clit = [] ; 
      clitAgr = CAgrNo ;
      obj = o
      } ;

  agrV : Verb -> Mood -> Tense -> Agr -> Str = \v,m,t,a -> case a of {
    Ag _ n p => case t of {
      Past => v.s ! VPast m n p ;
      Fut  => v.s ! VFut n p ;
      _    => v.s ! VPres m n p
      }
    } ;

  auxVerb : Aux -> Verb = \a -> case a of {
    Avere => 
      mkVerb "avere" "ho" "hai" "ha" "abbiamo" "avete" "hanno" 
             "avevo" "avr�" "abbia" "avessi" "avuto" Avere ;
    Essere => 
      mkVerb "essere" "sono" "sei" "�" "siamo" "siete" "sono" 
             "ero" "sar�" "sia" "fossi" "stato" Essere ---- eravamo
    } ;

  agrPart : Verb -> Agr -> ClitAgr -> Str = \v,a,c -> case v.aux of {
    Avere  => case c of {
      CAgr (Ag g n _) => v.s ! VPart g n ;
      _ => v.s ! VPart Masc Sg
      } ;
    Essere => case a of {
      Ag g n _ => v.s ! VPart g n
      }
    } ;

  neg : Bool -> Str = \b -> case b of {True => [] ; False => "non"} ;

  essere_V = auxVerb Essere ;

-- for coordination

  conjAgr : Number -> Agr -> Agr -> Agr = \n,xa,ya -> 
    let 
      x = agrFeatures xa ; y = agrFeatures ya
    in Ag 
      (conjGender x.g y.g) 
      (conjNumber (conjNumber x.n y.n) n)
      (conjPerson x.p y.p) ;

  agrFeatures : Agr -> {g : Gender ; n : Number ; p : Person} = \a -> 
    case a of {Ag g n p => {g = g ; n = n ; p = p}} ;

  conjGender : Gender -> Gender -> Gender = \g,h ->
    case g of {Masc => Masc ; _ => h} ;

  conjNumber : Number -> Number -> Number = \m,n ->
    case m of {Pl => Pl ; _ => n} ;

  conjPerson : Person -> Person -> Person = \p,q ->
    case <p,q> of {
      <Per1,_> | <_,Per1> => Per1 ;
      <Per2,_> | <_,Per2> => Per2 ;
      _                   => Per3
      } ;



-- for morphology

  Noun : Type = {s : Number => Str ; g : Gender} ;
  Adj  : Type = {s : Gender => Number => Str ; isPre : Bool} ;
  Verb : Type = {s : VForm => Str ; aux : Aux} ;

  mkNoun : Str -> Str -> Gender -> Noun = \vino,vini,g -> {
    s = table {Sg => vino ; Pl => vini} ;
    g = g
    } ;

  regNoun : Str -> Noun = \vino -> case vino of {
    fuo + c@("c"|"g") + "o" => mkNoun vino (fuo + c + "hi") Masc ;
    ol  + "io" => mkNoun vino (ol + "i") Masc ;
    vin + "o" => mkNoun vino (vin + "i") Masc ;
    cas + "a" => mkNoun vino (cas + "e") Fem ;
    pan + "e" => mkNoun vino (pan + "i") Masc ;
    _ => mkNoun vino vino Masc 
    } ;

  mkAdj : (_,_,_,_ : Str) -> Bool -> Adj = \buono,buona,buoni,buone,p -> {
    s = table {
          Masc => table {Sg => buono ; Pl => buoni} ;
          Fem  => table {Sg => buona ; Pl => buone}
        } ;
    isPre = p
    } ;

  regAdj : Str -> Adj = \nero -> case nero of {
    ner + "o"  => mkAdj nero (ner + "a") (ner + "i") (ner + "e") False ;
    verd + "e" => mkAdj nero nero (verd + "i") (verd + "i") False ;
    _ => mkAdj nero nero nero nero False
    } ;

  mkVerb : (x1,_,_,_,_,_,_,_,_,_,_,x12 : Str) -> Aux -> Verb = 
    \amare,amo,ami,ama,amiamo,amate,amano,amavo,amero,amic,amassi,amato,aux -> 
    let
      amav = init amavo ;
      amas = Predef.tk 2 amassi ;
      amer = init amero ;      
    in {
    s = table {
          VInf          => amare ;
          VInfContr     => init amare ;
          VPres Ind Sg Per1 => amo ;
          VPres Ind Sg Per2 => ami ;
          VPres Ind Sg Per3 => ama ;
          VPres Ind Pl Per1 => amiamo ;
          VPres Ind Pl Per2 => amate ;
          VPres Ind Pl Per3 => amano ;

          VPres Con Sg _    => amic ;
          VPres Con Pl Per1 => amiamo ;
          VPres Con Pl Per2 => Predef.tk 2 amiamo + "te" ;
          VPres Con Pl Per3 => amic + "no" ;

          VPast Ind Sg Per1 => amavo ;
          VPast Ind Sg Per2 => amav + "i" ;
          VPast Ind Sg Per3 => amav + "a" ;
          VPast Ind Pl Per1 => amav + "amo" ;
          VPast Ind Pl Per2 => amav + "ate" ;
          VPast Ind Pl Per3 => amav + "ano" ;

          VPast Con Sg Per1 => amassi ;
          VPast Con Sg Per2 => amassi ;
          VPast Con Sg Per3 => amas + "se" ;
          VPast Con Pl Per1 => amas + "simo" ;
          VPast Con Pl Per2 => amas + "te" ;
          VPast Con Pl Per3 => amas + "sero" ;

          VFut Sg Per1 => amero ;
          VFut Sg Per2 => amer + "ai" ;
          VFut Sg Per3 => amer + "�" ;
          VFut Pl Per1 => amer + "emo" ;
          VFut Pl Per2 => amer + "ete" ;
          VFut Pl Per3 => amer + "ono" ;

          VPart g n     => (regAdj amato).s ! g ! n
          } ;
    aux = aux
    } ;

  regVerb : Str -> Verb = \amare -> case amare of {
    am  + "are" => mkVerb amare (am+"o") (am+"i") (am+"a") 
                     (am+"iamo") (am+"ate") (am+"ano") 
                     (am +"avo") (am+"er�") (am+"i") (am+"assi") 
                     (am+"ato") Avere ;
    tem + "ere" => mkVerb amare (tem+"o") (tem+"i") (tem+"e") 
                     (tem+"iamo") (tem+"ete") (tem+"ono") 
                     (tem +"evo") (tem+"er�") (tem+"a") (tem+"essi") 
                     (tem+"uto") Avere ;
    fin + "ire" => mkVerb amare (fin+"isco") (fin+"isci") (fin+"isce") 
                     (fin+"iamo") (fin+"ite") (fin+"iscono") 
                     (fin +"ivo") (fin+"ir�") (fin+"isca") (fin+"issi") 
                     (fin+"ito") Avere
    } ; 

-- for structural words

  adjDet : Adj -> Number -> {s : Gender => Case => Str ; n : Number} = 
  \adj,n -> {
    s = \\g,c => prepCase c ++ adj.s ! g ! n ;
    n = n
    } ;

  pronNP : (s,a,d,i : Str) -> Gender -> Number -> Person -> NP = 
  \s,a,d,i,g,n,p -> {
    s = table {
      Nom => {clit = [] ; obj = s  ; isClit = False} ;
      Acc => {clit = a  ; obj = [] ; isClit = True} ;
      Dat => {clit = d  ; obj = [] ; isClit = True} ;
      c   => {clit = [] ; obj = prepCase c ++ i ; isClit = False}
      } ;
    a = Ag g n p
    } ;

-- phonological auxiliaries

  vowel    : pattern Str = #("a" | "e" | "i" | "o" | "u" | "h") ;
  s_impuro : pattern Str = #("z" | "s" + ("b"|"c"|"d"|"f"|"m"|"p"|"q"|"t")) ;

  elisForms : (_,_,_ : Str) -> Str = \lo,l',il ->
    pre {#s_impuro => lo ; #vowel => l' ; _ => il} ;

}
