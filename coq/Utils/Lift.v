(*
 * Copyright 2015-2016 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

(** This module contains definitions and properties of lifting
operations over option types. They are used extensively through the
code to propagate errors. *)

Require Import List.
Require Import RelationClasses.

Section Lift.

  (** * Lifting over option types *)

  Definition lift {A B:Type} (f:A->B) : (option A -> option B) 
    := fun a => 
         match a with
         | None => None 
         | Some a' => Some (f a')
         end.

  Definition olift {A B} (f:A -> option B) (x:option A) : option B :=
    match x with
    | None => None
    | Some x' => f x'
    end.

  Definition bind {A B:Type} a b := (@olift A B b a).

  Definition lift2 {A B C:Type} (f:A -> B -> C) (x:option A) (y:option B) : option C :=
    match x,y with
    | Some x', Some y' => Some (f x' y')
    | _,_ => None
    end.

  Definition olift_some {A B} (f:A -> option B) (x:A) :
    olift f (Some x) = f x.
  Proof. reflexivity. Qed.

  Definition olift2 {A B C} (f:A -> B -> option C) (x1:option A) (x2:option B) : option C :=
    match x1,x2 with
    | Some d1, Some d2 => f d1 d2
    | _,_ => None
    end.

  (** * Lift properties *)
  
  Lemma lift_some_simpl {A B:Type} (f:A->B) x : lift f (Some x) = Some (f x).
  Proof.
    reflexivity.
  Qed.

  Lemma lift_some_simpl_eq {A B:Type} (f:A->B) x y :
    f x = f y <->
    lift f (Some x) = Some (f y).
  Proof.
    simpl; split; [|inversion 1]; congruence.
  Qed.

  Lemma lift_none_simpl {A B:Type} (f:A->B) : lift f None = None.
  Proof. reflexivity. Qed.
  
  Lemma lift_none {A B:Type} {f:A->B} {x} :
    x = None -> 
    lift f x = None.
  Proof.
    intros; subst; reflexivity.
  Qed.

  Lemma lift_some {A B:Type} {f:A->B} {x y} z :
    x = Some z ->
    f z = y ->
    lift f x = Some y.
  Proof.
    intros; subst; reflexivity.
  Qed.

  Lemma none_lift {A B:Type} {f:A->B} {x} :
    lift f x = None ->
    x = None.
  Proof.
    destruct x; simpl; intuition discriminate.
  Qed.

  Lemma some_lift {A B:Type} {f:A->B} {x y} :
    lift f x = Some y ->
    {z | x = Some z & y = f z}.
  Proof.
    destruct x; simpl; intuition; [inversion H; eauto|discriminate].
  Qed.

  Lemma some_lift2 {A B C:Type} {f:A->B->C} {x y z} :
    lift2 f x y = Some z ->
    {x':A & {y':B | x = Some x' & y = Some y' /\ z = f x' y'}}.
  Proof.
    destruct x; simpl; intuition; [inversion H; eauto|discriminate].
    destruct y; simpl; intuition; [inversion H; eauto|discriminate].
  Qed.

  Lemma some_olift {A B:Type} {f:A->option B} {x y} :
    olift f x = Some y ->
    {z | x = Some z & Some y = f z}.
  Proof.
    destruct x; simpl; intuition; [inversion H; eauto|discriminate].
  Qed.

  Lemma some_olift2 {A B C:Type} {f:A->B->option C} {x y z} :
    olift2 f x y = Some z ->
    {x':A & {y':B | x = Some x' & y = Some y' /\ Some z = f x' y'}}.
  Proof.
    destruct x; simpl; intuition; [inversion H; eauto|discriminate].
    destruct y; simpl; intuition; [inversion H; eauto|discriminate].
  Qed.
  
  Lemma lift_injective {A B:Type} (f:A->B)  :
    (forall x y, f x = f y -> x = y) ->
    (forall x y, lift f x = lift f y -> x = y).
  Proof.
    destruct x; destruct y; simpl; inversion 1; auto.
    f_equal; auto.
  Qed.

  Lemma lift_id {A} (x:option A) :
    lift (fun l'' => l'') x = x.
  Proof.
    destruct x; reflexivity.
  Qed.

  Lemma match_lift_id {A} (x:option A) :
    match x with
    | None => None
    | Some l'' => Some l''
    end = x.
  Proof.
    destruct x; reflexivity.
  Qed.

  Lemma olift_id_lift_some {A} (x:option A) :
    olift id (lift Some x) = x.
  Proof.
    destruct x; simpl; reflexivity.
  Qed.


  Lemma olift2_none_r {A B C} (f:A -> B -> option C) (x1:option A) :
    olift2 f x1 None = None.
  Proof.
    destruct x1; reflexivity.
  Qed.

  Lemma olift2_somes {A B C} (f:A -> B -> option C) (x1:A) (x2:B) :
    olift2 f (Some x1) (Some x2) = f x1 x2.
  Proof. reflexivity. Qed.

  Lemma olift_ext {A B:Type} (f g : A -> option B) (x : option A) :
    (forall a, x = Some a -> f a = g a) ->
    olift f x = olift g x.
  Proof.
    destruct x; simpl; auto.
  Qed.

  Definition rif {A} (e:A -> option bool) (a:A) : option (list A) :=
    match (e a) with
    | None => None
    | Some b =>
      if b then Some (a::nil) else Some nil
    end.

  Definition lift2P {A B:Type} (P:A->B->Prop) (xo:option A) (yo:option B) : Prop
    := match xo, yo with
       | Some x, Some y => P x y
       | None, None => True
       | _ , _ => False
       end.

  (* Right Biased lift2P: if A is None, that is fine. *)
  Definition lift2Pl {A B:Type} (P:A->B->Prop) (xo:option A) (yo:option B) : Prop
    := match xo, yo with
       | Some x, Some y => P x y
       | None, _ => True
       | _ , _ => False
       end.

  (* Right Biased lift2P: if B is None, that is fine. *)
  Definition lift2Pr {A B:Type} (P:A->B->Prop) (xo:option A) (yo:option B) : Prop
    := match xo, yo with
       | Some x, Some y => P x y
       | _, None => True
       | _ , _ => False
       end.

      Global Instance lift2P_refl {A:Type} R {refl:@Reflexive A R} : Reflexive (lift2P R).
    Proof.
      unfold lift2P; intros x.
      destruct x; eauto. 
    Qed.

    Global Instance lift2P_sym {A:Type} R {refl:@Symmetric A R} : Symmetric (lift2P R).
    Proof.
      unfold lift2P; intros  x y.
      destruct x; destruct y; eauto.
    Qed.

    Global Instance lift2P_trans {A:Type} R {refl:@Transitive A R} : Transitive (lift2P R).
    Proof.
      unfold lift2P; intros x y z.
      destruct x; destruct y; destruct z; try contradiction; eauto.
    Qed.

    Global Instance lift2P_equiv {A:Type} R {refl:@Equivalence A R} : Equivalence (lift2P R).
    Proof.
      constructor.
      - red; intros; reflexivity.
      - red; intros; symmetry; trivial.
      - red; intros; etransitivity; eauto.
    Qed.

End Lift.

Hint Rewrite @olift_some : alg.
Hint Rewrite @olift2_none_r : alg.
Hint Rewrite @olift2_somes : alg.

(** * Tactics *)

Ltac case_option 
  := match goal with
       [|- context [match ?x with
                    | Some _ => _
                    | None => _
                    end]] => case_eq x
     end.

Ltac case_lift 
  := match goal with
       [|- context [lift _ ?x]] => case_eq x
     end.

Ltac case_option_in H
  := match type of H with
       context [match ?x with
                | Some _ => _
                | None => _
                end] => let HH:=(fresh "eqs") in case_eq x; [intros ? HH|intros HH]; try rewrite HH in H
     end.

Ltac case_lift_in H
  := match type of H with
       context [lift _ ?x] => let HH:=(fresh "eqs") in case_eq x; [intros ? HH|intros HH]; try rewrite HH in H
     end.

