(*
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

(** Imp is a simpl imperative intermediate language. *)

Require Import String.
Require Import List.
Require Import Bool.
Require Import Arith.
Require Import Utils.
Require Import JsAst.JsNumber.
Require Import EJsonRuntime.
Require Import Imp.
Require Import ImpEJson.
Require Import ImpEJsonVars.
Require Import ImpEJsonEval.

Section ImpEJsonRewrite.
  Import ListNotations.

  Context {fejson:foreign_ejson}.
  Context {fejruntime:foreign_ejson_runtime}.

  Definition imp_ejson_rewrite (q:imp_ejson) : imp_ejson := q.

  Lemma imp_ejson_rewrite_correct h (j : ejson) (q:imp_ejson) :
    imp_ejson_eval h q j =
    imp_ejson_eval h (imp_ejson_rewrite q) j.
  Proof. reflexivity. Qed.

End ImpEJsonRewrite.
