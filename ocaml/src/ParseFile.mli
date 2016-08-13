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

(* This module contains parsing utilities *)

open Compiler.EnhancedCompiler
open ParseUtil

(*******************)
(* Parse from file *)
(*******************)

val parse_io_from_file : string -> Data.json
val parse_json_from_file : string -> Data.json

val parse_rule_from_file : string -> string * CompDriver.query
val parse_camp_from_file : string -> CompDriver.camp

val parse_oql_from_file : string -> CompDriver.oql

(****************)
(* S-Expr Parse *)
(****************)

val parse_sexp_from_file : string -> SExp.sexp
val parse_io_sexp_from_file : string -> Data.data
val parse_camp_sexp_from_file : string -> CompDriver.camp
val parse_nraenv_sexp_from_file : string -> CompDriver.nraenv
val parse_nnrc_sexp_from_file : string -> CompDriver.nnrc
val parse_nnrcmr_sexp_from_file : string -> CompDriver.nnrcmr
val parse_cldmr_sexp_from_file : string -> CompDriver.cldmr

(*******************
 * Languages Parse *
 *******************)

val parse_language_from_file : CompDriver.language -> string -> string * CompDriver.query

