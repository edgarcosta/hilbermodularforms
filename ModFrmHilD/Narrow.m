intrinsic ShintaniWalls(bb::RngOrdFracIdl) -> Any
  {returns lower, upper}
  F := NumberField(Parent(Order(bb).1));
  assert Degree(F) le 2;
  places := InfinitePlaces(F);
  eps := FundamentalUnit(F);
  // TODO some fixes based on narrow equals class..
  if not IsTotallyPositive(eps) then
    eps := eps^2;
  end if;
  eps1 := Evaluate(eps, places[1]);
  eps2 := Evaluate(eps, places[2]);
  if eps1/eps2 le eps2/eps1 then
    return Sqrt(eps1/eps2), Sqrt(eps2/eps1);
  else
    return Sqrt(eps2/eps1), Sqrt(eps1/eps2);
  end if;
end intrinsic;

// TODO
intrinsic ShintaniCone(bb::RngOrdFracIdl, t::RngIntElt) -> SeqEnum[RngOrdFracIdl]
  {Given bb and element of the narrow class group, t a trace, }
  F := NumberField(Parent(Order(bb).1));
  basis := Basis(bb);
end intrinsic;

// TODO
intrinsic ShintaniCone(bb::RngOrdFracIdl, t::RngIntElt) -> Any
  {returns all totally positive elements in the shintani cone for bb up to trace t}
end intrinsic;
















//////////////////////////////////////////////////

///////////// Ben Code for checking ////////////////


//Returns the walls of the Shintani domain
intrinsic Shintani_Walls(bb::RngOrdFracIdl) -> Any
  {returns lower, upper}
  F := NumberField(Parent(Order(bb).1));
  assert Degree(F) le 2;
  places := InfinitePlaces(F);
  eps := FundamentalUnit(F);
  if Norm(eps) eq -1 then
      // In this case CK = CK^+ so the totally positive units are squares i.e. the subgroup generated by eps^2
      eps := eps^2;
  else 
      if not IsTotallyPositive(eps) then
      // In this case CK not equal to CK^+ so there are no units of mixed signs. If the fundamental unit is not totally positive we multiply by -1 
         eps := -1*eps;
      end if;
  end if;
  eps1 := Evaluate(eps, places[1]);
  eps2 := Evaluate(eps, places[2]);
  if eps1/eps2 le eps2/eps1 then
    return Sqrt(eps1/eps2), Sqrt(eps2/eps1);
  else
    return Sqrt(eps2/eps1), Sqrt(eps1/eps2);
  end if;
end intrinsic;




// Takes an ideal bb and returns a basis {a,b} where Tr(a) = n and Tr(b) = 0. 
intrinsic Nice_Basis(bb::RngOrdFracIdl) -> SeqEnum
  {Input: bb fractional ideal
   Output: A basis for bb that puts the trace in Smith normal form}
  
  basis := Basis(bb);
  ZF := Parent(basis[2]);
  Tr := Matrix([[Trace(basis[i]) : i in [1..#basis]]]);
  _,_,Q := SmithForm(Tr);
  ChangeofBasisMatrix := ChangeRing(Q,ZF);
  NewBasis := Eltseq(Vector(basis)*ChangeofBasisMatrix);
  return NewBasis;
end intrinsic;



// Elements of the Shintani Domain with trace t
/*
Idea: I've hopefully obtained basis {a,b} for the ideal bb where Tr(a) = n and Tr(b) = 0. Elements in ideal will look like xa+yb where x,y \in Z and have embedding xa_1+ yb_1 and xa_2+ yb_2. 
All totally positive elements of given trace t will satisfy

1).    t = Tr(xa+yb)    <=>   t = xn
2).    C_1 < (xa_1+yb_1)/(xa_2+yb_2) < C_2.     <=>   (C_1*x*a_2 -x*a_1)/(b_1-C_1*b_2) < y   and  y < (C_2*x*a_2 -x*a_1)/(b_1-C_2*b_2)

where C1 and C2 are the slope bounds on the shintani domain. Eq 1) determines the value for x while Eq 2) allows us to loop over values of y
*/


intrinsic Pos_elt_of_Trace_in_Shintani_Domain(bb::RngOrdFracIdl, t::RngIntElt, places::[PlcNumElt]) -> SeqEnum[RngOrdFracIdl]
  {Input: bb: fractional ideal.    t: bound on the trace.    places: The infinite places of the numberfield.
   Output: The totally positive elements of bb in the balance shintani cone with trace t}
  Basis := Nice_Basis(bb);
  SmallestTrace := Trace(Basis[1]);

  T := [];
  if t mod SmallestTrace eq 0 then
    x := t div SmallestTrace;
    C1,C2 := Shintani_Walls(bb);
    a_1 := Evaluate(Basis[1],places[1]); b_1 := Evaluate(Basis[2],places[1]);
    a_2 := Evaluate(Basis[1],places[2]); b_2 := Evaluate(Basis[2],places[2]);
    B1 := (C1*x*a_2 -x*a_1)/(b_1-C1*b_2); B2 := (C2*x*a_2 -x*a_1)/(b_1-C2*b_2);
    Lower := Ceiling(Min(B1,B2));
    Upper := Max(B1,B2);
    
    // I need to make sure I don't include points that lie on both walls. This is bad code but removes points that lie on upper wall
    if (Upper - Floor(Upper)) lt 10^(-70) then Upper := Floor(Upper)-1; else Upper := Floor(Upper); end if;

    for y in [Lower .. Upper] do
      Append(~T, x*Basis[1]+y*Basis[2]);
    end for;
  end if;
  return T;
end intrinsic;


// Computing the Shintani domain  
intrinsic Shintani_Domain(bb::RngOrdFracIdl,N::RngIntElt) -> List
  {Returns Shintani Domain of bb up to trace N}
  F := NumberField(Parent(Order(bb).1));
  assert Degree(F) le 2;
  places := InfinitePlaces(F);
  ShintaniDom := &cat [Pos_elt_of_Trace_in_Shintani_Domain(bb,i,places) : i in [1..N]];
  return ShintaniDom;
end intrinsic;    









//////////// Extra for later on ////////////////

// The totally positive elts of given trace 
/*
Idea: I've hopefully obtained basis {a,b} for the ideal bb where Tr(a) = n and Tr(b) = 0. Elements in ideal will look like xa+yb where x,y \in Z and have embedding xa_1+ yb_1 and xa_2+ yb_2. 
All totally positive elements of given trace t will satisfy

1).    t = Tr(xa+yb)    <=>   t = xn
2).    xa+yb >> 0.     <=>   y > -x*a_1/b_1   and  y > -x*a_2/b_2 

Eq 1) determines the value for x while Eq 2) allows us to loop over values of y
*/

intrinsic Pos_elt_of_Trace(bb::RngOrdFracIdl, t::RngIntElt, places::[PlcNumElt]) -> SeqEnum[RngOrdFracIdl]
  {Input: bb: fractional ideal.    t: bound on the trace.    places: The infinite places of the numberfield.
   Output: The totally positive elements of bb with trace t}
  Basis := Nice_Basis(bb);
  SmallestTrace := Trace(Basis[1]);

  T := [];
  if t mod SmallestTrace eq 0 then
    x := t div SmallestTrace;
    a_1 := Evaluate(Basis[1],places[1]); b_1 := Evaluate(Basis[2],places[1]);
    a_2 := Evaluate(Basis[1],places[2]); b_2 := Evaluate(Basis[2],places[2]);
    Lower := Ceiling(Min(-x*a_1/b_1,-x*a_2/b_2));
    Upper := Floor(Max(-x*a_1/b_1,-x*a_2/b_2));
    for y in [Lower .. Upper] do
      Append(~T, [x*Basis[1]+y*Basis[2]]);
    end for;
  end if;
  return T;
end intrinsic;



