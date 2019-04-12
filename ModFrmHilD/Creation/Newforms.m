

////////// Creation of CuspForms from ModFrmHilDElt //////////

intrinsic CoefficientsFromRecursion(M::ModFrmHilD, N::RngOrdIdl, n::RngOrdIdl, k::SeqEnum[RngIntElt], coeff::Assoc) -> RngIntElt
  {construct the coefficient for a_n from an associative array coeff with all a_p for p|n}
  ZF := Integers(M);
  k0 := Max(k); 
  Fact := Factorization(n);
  // Power series ring for recusion
  ZFX<X, Y> := PolynomialRing(ZF, 2);
  prec := Max([pair[2]: pair in Fact]) +1;
  R<T> := PowerSeriesRing(ZFX : Precision := prec);
  recursion := Coefficients(1/(1 - X*T + Y*T^2));
  // If good, then 1/(1 - a_p T + Norm(p) T^2) = 1 + a_p T + a_{p^2} T^2 + ...
  // If bad, then 1/(1 - a_p T) = 1 + a_p T + a_{p^2} T^2 + ...
  coeff_I := 1;
  for pair in Fact do 
    pp := pair[1];
    Np := Norm(pp)^(k0-1);
    // if pp is bad
    if N subset pp then
      Np := 0;
    end if;
    coeff_I *:= Evaluate(recursion[pair[2]], [coeff[pp], Np]);
  end for;
  return coeff_I;
end intrinsic;


intrinsic NewformToHMF(M::ModFrmHilD, N::RngOrdIdl, k::SeqEnum[RngIntElt], newform::ModFrmHilElt) -> ModFrmHilDElt
  {Construct the ModFrmHilDElt in M determined (on prime ideals up to norm prec) by hecke_eigenvalues.}
  ZF := Integers(M);
  coeffs := AssociativeArray(); // Coefficient array indexed by ideals

  // Step 1: a_0 and a_1
  coeffs[0*ZF] := 0; coeffs[1*ZF] := 1;
  // Step 2: a_p for primes 
  for pp in AllPrimes(M) 
    do coeffs[pp] := HeckeEigenvalue(newform, pp);
  end for;
  // Step 3: a_n for composite ideals
  for I in AllIdeals(M) do 
    if I notin Keys(coeffs) then 
      coeffs[I] := CoefficientsFromRecursion(M,N,I,k,coeffs);
    end if;
  end for;

  // Storing coefficients
  CoeffsArray := AssociativeArray();
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do
    CoeffsArray[bb] := AssociativeArray();
    for nn in IdealsByNarrowClassGroup(M)[bb] do
      CoeffsArray[bb][nn] := coeffs[nn];
    end for;
  end for;
  return HMF(M, N, k, CoeffsArray);
end intrinsic;


intrinsic NewformsToHMF(M::ModFrmHilD, N::RngOrdIdl, k::SeqEnum[RngIntElt]) -> SeqEnum[ModFrmHilDElt]
  {returns Hilbert newforms} 
  F := BaseField(M); 
  prec := Precision(M); 
  MF := HilbertCuspForms(F, N, k); 
  S := NewSubspace(MF); 
  newspaces  := NewformDecomposition(S); 
  newforms := [* Eigenform(U) : U in newspaces *]; 
  HMFnewforms := [**]; 
  for newform in newforms do
    NewHMF := NewformToHMF(M, N, k, newform);
    Append(~HMFnewforms, NewHMF); 
  end for; 
  return HMFnewforms;
end intrinsic; 

/*
intrinsic NewformsToHMF2(M::ModFrmHilD, k::SeqEnum[RngIntElt]) -> SeqEnum[ModFrmHilDElt]
  {returns Hilbert newforms}
  F := BaseField(M);
  N := Level(M); //input
  prec := Precision(M);
  HeckeEigenvalue := HeckeEigenvalues(M);
  key :=  [* N, k *];
  if not IsDefined(M, key) then
    MF := HilbertCuspForms(F, N, k);
    S := NewSubspace(MF);
    newspaces  := NewformDecomposition(S);
    newforms := [* Eigenform(U) : U in newspaces *];
    primes := Primes(M);
    EVnewforms := [];
    for newform in newforms do
      eigenvalues := [];
      for i in [1..#primes] do
          eigenvalues[i] := HeckeEigenvalue(newform, primes[i]);
      end for;
      Append(~EVnewforms, eigenvalues);
    end for;
    HeckeEigenvalue[key] := EVnewforms;
  else
    EVnewforms := HeckeEigenvalue[key];
  end if;
  HMFnewforms := [];
  for eigenvalues in EVnewforms do
      ef := EigenformToHMF(M, k, eigenvalues); //FIXME, this is not correct
      Append(~HMFnewforms, ef);
    end for;
  return HMFnewforms;
end intrinsic;
*/