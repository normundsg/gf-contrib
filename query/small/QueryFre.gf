--# -path=.:alltenses

concrete QueryFre of Query = open
  ParadigmsFre,
  SyntaxFre,
  ExtraFre,
  (G = GrammarFre),
  SymbolicFre,
  Prelude
in {

flags coding = utf8 ;

-- for a baseline: just change these lexical entries
oper
  about_Prep = on_Prep ;
  also_AdV = lin AdV (ss "aussi") ;
  as_Prep = mkPrep "comme" ;
  at_Prep = mkPrep "chez" ;
  called_A = mkA "appelé" ;
  give_V = mkV "montrer" ;
  information_N = mkN "information" ;
  other_A = prefixA (mkA "autre") ;
  name_N = mkN "nom" ;
  nickname_N = mkN "surnom" ;
  located_A = mkA "situé" ;
  employed_A = mkA "employé" ;
  work_V = mkV "travailler" ;
  position_N = mkN "poste" masculine ;
  organization_N =  mkN "organisation" ;
  place_N = mkN "endroit" ;
  person_N = mkN "personne" ;
  location_N = mkN "position" ;
  region_N = mkN "région" ;
  subregion_N = mkN "sous-région" ;

lincat
  Move = Utt ; ---- Text ;
  Query = Utt ;
  Answer = Utt ;
  Set = NP ;
  Relation = {cn : CN ; prep : Prep} ;
  Kind = CN ;
  Property = AP ; ---- {vp : VP ; typ : PropTyp} ;
  Individual = NP ;
  Activity = VP ;
  Name = NP ;
  Loc = NP ;
  Org = NP ;
  Pers = NP ;
  [Individual] = [NP] ;

lin
  MQuery  q = q ;
  MAnswer a = a ;

  QSet s = mkUtt (mkVP (mkV2 give_V) s) ;

  QWhere s = mkUtt (mkQS (mkQCl where_IAdv s)) ;
  QInfo s = mkUtt (mkVP (mkV2 give_V) 
              (mkNP all_Predet (mkNP thePl_Det (mkCN information_N (mkAdv on_Prep s))))) ;

  QCalled i = mkUtt (mkQS (mkQCl (mkIP whichSg_IDet (mkCN other_A name_N)) i have_V2)) ; 

  AKind s k = mkUtt (mkCl s (mkNP aPl_Det k)) ;
  AProp s p = mkUtt (mkCl s p) ;
  AAct s p = mkUtt (mkCl s p) ;

  SAll k = mkNP all_Predet (mkNP thePl_Det k) ;
  SOne k = mkNP n1_Numeral k ;
  SIndef k = mkNP someSg_Det k ;
  SPlural k = mkNP aPl_Det k ;
  SOther k = mkNP aPl_Det (mkCN other_A k) ;
  SInd i = i ;
  SInds is = mkNP and_Conj is ;

  KRelSet r s = mkCN r.cn (mkAdv r.prep s) ;
  KRelKind k r s = mkCN k (mkRS (mkRCl which_RP (mkVP (mkNP aPl_Det (mkCN r.cn (mkAdv r.prep s)))))) ;

  KRelPair k r = mkCN k (mkAdv with_Prep (mkNP (mkQuant they_Pron) plNum r.cn)) ;
  KProp p k = mkCN p k ;
  KAct p k = mkCN k (mkRS (mkRCl which_RP p)) ;
  KRel r = r.cn ;

  IName n = n ;
  NLoc n = n ;
  NOrg n = n ;
  NPers n = n;

  ACalled is = mkVP also_AdV (mkVP (mkAP (mkA2 called_A (mkPrep "")) (mkNP or_Conj is))) ;

  BaseIndividual = mkListNP ;
  ConsIndividual = mkListNP ;

oper

-- lexical constructors
  mkName : Str -> NP =
    \s -> mkNP (mkPN s) ;
  mkRelation : N -> {cn : CN ; prep : Prep} =
    \s -> {cn = mkCN s ; prep = possess_Prep} ;

-- lexicon

lincat
  JobTitle = CN ;
lin
  Located i = mkAP (mkA2 located_A in_Prep) i ;
  Employed i = mkAP (mkA2 employed_A at_Prep) i ;
  Work i = mkVP (mkV2 work_V at_Prep) i ;

  HaveTitle t = mkVP have_V2 (mkNP the_Det (mkCN position_N (mkAdv possess_Prep (mkNP t)))) ;
  HaveTitleOrg t i = mkVP (mkVP have_V2 (mkNP the_Det (mkCN position_N (mkAdv possess_Prep (mkNP t))))) (mkAdv in_Prep i) ;

  Organization = mkCN organization_N ;
  Place = mkCN place_N ;
  Person = mkCN person_N ;

  Location = mkRelation location_N ;
  Region = mkRelation region_N ;
  Subregion = mkRelation subregion_N ;
  RName = mkRelation name_N ;
  RNickname = mkRelation nickname_N ;

-- JobTitles
  JobTitle1 = mkCN (mkN "'JobTitle1") ;
  JobTitle2 = mkCN (mkN "'JobTitle2") ;
  JobTitle3 = mkCN (mkN "'JobTitle3") ;
  JobTitle4 = mkCN (mkN "'JobTitle4") ;

-- Locations
  Location1 = mkName "'Location1" ;
  Location2 = mkName "'Location2" ;
  Location3 = mkName "'Location3" ;
  Location4 = mkName "'Location4" ;

-- Organizations
  Organization1 = mkName "'Organization1" ;
  Organization2 = mkName "'Organization2" ;
  Organization3 = mkName "'Organization3" ;
  Organization4 = mkName "'Organization4" ;

-- Persons
  Person1 = mkName "'Person1" ;
  Person2 = mkName "'Person2" ;
  Person3 = mkName "'Person3" ;
  Person4 = mkName "'Person4" ;


}
