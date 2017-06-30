pub const visible_magic: u32 = 0x971e137b;
pub const hidden_magic_a: u32 = 0x95543787;
pub const hidden_magic_b: u32 = 0x2ad7eb25;
pub const visible_mixer: u32 = 0x52dce729;
pub const hidden_mixer_a: u32 = 0x7b7d159c;
pub const hidden_mixer_b: u32 = 0x6bce6396;
pub const final_mixer_1: u32 = 0x85ebca6b;
pub const final_mixer_2: u32 = 0xc2b2ae35;
pub const seed_string: u32 = 0xf7ca7fd2;

pub fn start_hash(seed: u32) -> u32 {
    seed ^ visible_magic
}

pub fn string_hash(s: String) -> u32 {
    let mut h = start_hash((s.len() as u32).wrapping_mul(seed_string));
    let mut c = hidden_magic_a;
    let mut k = hidden_magic_b;
    let mut j = 0;
    while j + 1 < s.len() {
        let i = (s.chars().nth(j).unwrap() as u32)
            .overflowing_shl(16)
            .0
            .wrapping_add(s.chars().nth(j + 1).unwrap() as u32);
        h = extend_hash(h, i, c, k);
        c = next_magic_a(c);
        k = next_magic_b(k);
        j += 2;
    }
    if j < s.len() {
        h = extend_hash(h, s.chars().nth(j).unwrap() as u32, c, k);
    }
    finalize_hash(h)
}

pub fn extend_hash(hash: u32, value: u32, magic_a: u32, magic_b: u32) -> u32 {
    (hash ^ rotate_left(value.wrapping_mul(magic_a), 11).wrapping_mul(magic_b))
        .wrapping_mul(3)
        .wrapping_add(visible_mixer)
}

pub fn next_magic_a(magic_a: u32) -> u32 {
    magic_a.wrapping_mul(5).wrapping_add(hidden_mixer_a)
}

pub fn next_magic_b(magic_b: u32) -> u32 {
    magic_b.wrapping_mul(5).wrapping_add(hidden_mixer_b)
}

pub fn finalize_hash(hash: u32) -> u32 {
    let mut i = hash ^ hash.overflowing_shr(16).0;
    i = i.wrapping_mul(final_mixer_1);
    i ^= i.overflowing_shr(13).0;
    i = i.wrapping_mul(final_mixer_2);
    i ^= i.overflowing_shr(16).0;
    i
}

fn rotate_left(value: u32, shift: u32) -> u32 {
    value.overflowing_shl(shift).0 | value.overflowing_shr(64 - shift).0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hashes() {
        let inputs = ["hello", "world", "foo", "bar"];
        let outputs = [698990018, 226145344, 1649972816, 2119248271];

        for (input, output) in inputs.iter().zip(outputs.iter()) {
            assert_eq!(string_hash(input.to_string()), *output);
        }
    }
}
