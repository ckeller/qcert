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

(** NNRCimp is a variant of the named nested relational calculus
     (NNRC) that is meant to be more imperative in feel.  It is used
     as an intermediate language between NNRC and more imperative /
     statement oriented backends *)

Section NNRCimp.
  Require Import String.
  Require Import List.
  Require Import Arith.
  Require Import EquivDec.
  Require Import Morphisms.
  Require Import Arith.
  Require Import Max.
  Require Import Bool.
  Require Import Peano_dec.
  Require Import EquivDec.
  Require Import Decidable.
  Require Import Utils.
  Require Import CommonRuntime.

  Section Syntax.

    Context {fruntime:foreign_runtime}.
    
    Inductive nnrc_imp_expr :=
    | NNRCimpGetConstant : var -> nnrc_imp_expr                           (**r global variable lookup ([$$v]) *)
    | NNRCimpVar : var -> nnrc_imp_expr                                   (**r local variable lookup ([$v])*)
    | NNRCimpConst : data -> nnrc_imp_expr                                (**r constant data ([d]) *)
    | NNRCimpBinop : binary_op -> nnrc_imp_expr -> nnrc_imp_expr -> nnrc_imp_expr           (**r binary operator ([e₁ ⊠ e₂]) *)
    | NNRCimpUnop : unary_op -> nnrc_imp_expr -> nnrc_imp_expr                     (**r unary operator ([⊞ e]) *)
    | NNRCimpGroupBy : string -> list string -> nnrc_imp_expr -> nnrc_imp_expr    (**r group by expression ([e groupby g fields]) -- only in full NNRC *)
    .

    Inductive nnrc_imp_stmt :=
    | NNRCimpSeq : nnrc_imp_stmt -> nnrc_imp_stmt -> nnrc_imp_stmt                   (**r for loop ([{ e₂ | $v in e₁ }]) *)
    | NNRCimpLetMut : var -> option (nnrc_imp_expr) -> nnrc_imp_stmt -> nnrc_imp_stmt                   (**r let expression ([let $v := e₁ in e₂]) *)
    (** This creates a mutable collection, and evaluates the first
    statement with it bound to the given variable.  It then freezes
    the collection (makes it a normal bag) and evaluates the second
    statement with the variable bound to the bag version *)
    | NNRCimpBuildCollFor : var -> nnrc_imp_stmt -> nnrc_imp_stmt -> nnrc_imp_stmt
    (* pushes to a variable that holds a mutable collection *)
    | NNRCimpPush : var -> nnrc_imp_expr -> nnrc_imp_stmt 
    | NNRCimpAssign : var -> nnrc_imp_expr -> nnrc_imp_stmt
    | NNRCimpFor : var -> nnrc_imp_expr -> nnrc_imp_stmt -> nnrc_imp_stmt                   (**r for loop ([{ e₂ | $v in e₁ }]) *)
    | NNRCimpIf : nnrc_imp_expr -> nnrc_imp_stmt -> nnrc_imp_stmt -> nnrc_imp_stmt                   (**r conditional ([e₁ ? e₂ : e₃]) *)
    | NNRCimpEither : nnrc_imp_expr -> var -> nnrc_imp_stmt -> var -> nnrc_imp_stmt -> nnrc_imp_stmt (**r case expression ([either e left $v₁ : e₁ | right $v₂ : e₂]) *)
.
    Definition nnrc_imp := nnrc_imp_stmt.

  End Syntax.
  
End NNRCimp.

