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

Require Import String.
Require Import List.
Require Import Arith.
Require Import EquivDec.
Require Import Morphisms.

Require Import Utils BasicRuntime.

Require Import LambdaNRA LambdaNRAEq LambdaNRAtoNRAEnv.
Require Import TrivialCompiler.
Import TrivialCompiler.

Section DatasetTests.
  Require Import LambdaNRATest.

  
  (* A4 : Persons.map{p => p.name} *)

  Definition A4 :=
    LNRAMap (LNRALambda "p" (LNRAUnop (ADot "name") (LNRAVar "p"))) (LNRATable "Persons").

  Require Import CompDriver.

  (* LambdaNRA to DNNRC *)
  Definition a := lambda_nra_to_nraenv A4.
  Definition b := nraenv_to_nnrc a.
  Definition c := nnrc_to_dnnrc_dataset (("Persons"%string,Vdistr)::nil) b.

  (* Typing stuffs for then next steps *)
  Require Import CAMPTest.
  Require Import BasicSystem.
  Require Import TrivialModel.
  Require Import TDataTest.

  Require Import Program.
  
  Require Import TCAMPTest.
  Existing Instance CPModel.
  Definition PersonsType := Tdistr CustomerType.
  Definition tdenv :tdbindings := (("CONST$Persons"%string,PersonsType)::nil).

  (* Eval vm_compute in c. *)
  
  Definition d := dnnrc_dataset_to_dnnrc_typed_dataset c tdenv.

  Definition e:= lift dnnrc_typed_dataset_optim d.
  
  (* Eval stuffs *)
  Require Import CompEval.

  Require Import NRATest.
  Definition env := (("CONST$Persons"%string,persons)::nil).
  Definition ev := lift (fun x => @eval_dnnrc_typed_dataset _ _ _ [] x env) e.

  (* Eval vm_compute in e. *)

End DatasetTests.

(* 
*** Local Variables: ***
*** coq-load-path: (("../../coq" "Qcert")) ***
*** End: ***
*)
