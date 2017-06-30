#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

mod MurmurHash;

use MurmurHash::{start_hash, extend_hash, finalize_hash, start_magic_a, start_magic_b, next_magic_a, next_magic_b, string_hash};
use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};

mod atoms {
    rustler_atoms! {
        //atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.LastOrder.Hash.Murmur",
    [("start_hash", 1, nif_start_hash),
     ("extend_hash", 4, nif_extend_hash),
     ("finalize_hash", 1, nif_finalize_hash),
     ("start_magic_a", 0, nif_start_magic_a),
     ("start_magic_b", 0, nif_start_magic_b),
     ("next_magic_a", 1, nif_next_magic_a),
     ("next_magic_b", 1, nif_next_magic_b),
     ("string_hash", 1, nif_string_hash)
    ],
    None
}

fn nif_start_hash<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let seed: u32 = args[0].decode()?;
    Ok(start_hash(seed).encode(env))
}

fn nif_extend_hash<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let hash: u32 = args[0].decode()?;
    let value: u32 = args[1].decode()?;
    let magic_a: u32 = args[2].decode()?;
    let magic_b: u32 = args[3].decode()?;

    Ok(extend_hash(hash, value, magic_a, magic_b).encode(env))
}

fn nif_finalize_hash<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let hash: u32 = args[0].decode()?;
    Ok(finalize_hash(hash).encode(env))
}

fn nif_start_magic_a<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    Ok(start_magic_a().encode(env))
}

fn nif_start_magic_b<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    Ok(start_magic_b().encode(env))
}

fn nif_next_magic_a<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let magic_a: u32 = args[0].decode()?;
    Ok(next_magic_a(magic_a).encode(env))
}

fn nif_next_magic_b<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let magic_b: u32 = args[0].decode()?;
    Ok(next_magic_b(magic_b).encode(env))
}

fn nif_string_hash<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let s: String = args[0].decode()?;
    Ok(string_hash(s).encode(env))
}
