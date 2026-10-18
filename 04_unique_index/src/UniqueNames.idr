module UniqueNames

import Data.List.Extra
import Data.String

import Data.Fuel

import public Test.DepTyCheck.Gen
import System.Random.Pure.StdGen

%default total


-- public export
-- data SVect : (len : Nat) -> Type where
--   ||| Empty vector
--   Nil  : SVect Z
--   ||| A non-empty vector of length `S len`, consisting of a head element and
--   ||| the rest of the list, of length `len`.
--   (::) : (x : String) -> (xs : SVect len) -> SVect (S len)

-- export
-- (++) : SVect a -> SVect b -> SVect (a + b)
-- (++) [] xs = xs
-- (++) (x :: xs) ys = x :: (xs ++ ys)

-- (.length) : SVect l -> Nat
-- (.length) [] = Z
-- (.length) (x :: xs) = S xs.length

-- export
-- toVect : SVect l -> Vect l String
-- toVect [] = []
-- toVect (x :: xs) = x :: toVect xs

data UniqNames : (l : Nat) -> Vect l String -> Type
data NameNotIn : (l : Nat) -> (names : Vect l String) -> (name : String) -> Type

public export
data UniqNames : (l : Nat) -> Vect l String -> Type where
  Empty : UniqNames 0 []
  Cons : {l : Nat} -> (names : Vect l String) -> (name: String) -> UniqNames l names -> NameNotIn l names name -> UniqNames (S l) (name :: names)

public export
data NameNotIn : (l : Nat) -> (names : Vect l String) -> (name : String) -> Type where
  NNPEmpty : NameNotIn 0 [] s
  NNPCons : (0 _ : So $ x /= name) -> (npi : NameNotIn l xs name) -> NameNotIn (S l) (x :: xs) name


public export
data NameIsNewAndNonKeyword : (keywords : Vect lk String) -> (names : Vect l String) -> (un : UniqNames l names) -> (name : String) -> Type where
  NINANK : NameNotIn l names name -> NameNotIn lk keywords name -> NameIsNewAndNonKeyword keywords names un name

export
rawNewName' : Fuel ->
              (Fuel -> Gen MaybeEmpty String) =>
              {l : Nat} -> {lk : Nat} ->
              (keywords : Vect lk String) ->
              (names : Vect l String) ->
              (un : UniqNames l names) ->
              Gen MaybeEmpty (s ** NameIsNewAndNonKeyword keywords names un s)

rawNewName : Fuel -> (Fuel -> Gen MaybeEmpty String) =>
             {l : Nat} -> (names : Vect l String) -> (un : UniqNames l names) -> {lk : Nat} -> (keywords : Vect lk String) ->
             Gen MaybeEmpty (s ** NameNotIn l names s)
rawNewName f @{g} names un kw = do
  (s ** NINANK a b) <- rawNewName' f @{g} kw names un
  pure (s ** a)

namesGen : Gen0 String
namesGen = pack <$> listOf {length = choose (1,10)} (choose ('a', 'z'))

export
namesGen' : Fuel -> Gen MaybeEmpty String
namesGen' _ = namesGen

export
genOneUniqueName : {lk : Nat} -> (keywords : Vect lk String) -> {l : Nat} -> Fuel -> (names : Vect l String) -> (un : UniqNames l names) ->
                   Gen MaybeEmpty (out : String ** UniqNames (S l) (out :: names))
genOneUniqueName kw x names un = do
  (name ** uname) <- rawNewName x @{namesGen'} names un kw
  pure (name ** Cons names name un uname)

export
genNUniqueNames : {lk : Nat} -> (keywords : Vect lk String) -> {l : Nat} -> Fuel -> (n : Nat) -> (names : Vect l String) -> (un : UniqNames l names) ->
                  Gen MaybeEmpty (newNames : Vect n String ** UniqNames (n + l) (newNames ++ names))
genNUniqueNames kw _ Z     names un = pure ([] ** un)
genNUniqueNames kw x (S k) names un = do
  (tail ** utail) <- genNUniqueNames kw x k names un
  (head ** uhead) <- genOneUniqueName kw x (tail ++ names) utail
  pure (head :: tail ** uhead)
