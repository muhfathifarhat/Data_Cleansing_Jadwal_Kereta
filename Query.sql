 with new_table as(
  select
    distinct trim(upper(id_jadwal)) id_jadwal,
    initcap(trim(nama_kereta)) nama_kereta,
    trim(nomor_kereta) nomor_kereta,
    trim(stasiun_asal) stasiun_asal,
    trim(stasiun_tujuan) stasiun_tujuan,

    -- FORMAT TANGGAL BERANGKAT
    case
      when regexp_contains(trim(tanggal_berangkat), r'^\d{2}/\d{2}/\d{4}$')
      then parse_date('%d/%m/%Y', trim(tanggal_berangkat))

      when regexp_contains(trim(tanggal_berangkat), r'^\d{2} [A-Za-z]{3} \d{4}$')
      then parse_date('%d %b %Y', trim(tanggal_berangkat))

      when regexp_contains(trim(tanggal_berangkat), r'^\d{2}-\d{2}-\d{4}$')
      then parse_date('%d-%m-%Y', trim(tanggal_berangkat))

      when regexp_contains(trim(tanggal_berangkat), r'^\d{4}-\d{2}-\d{2}$')
      then parse_date('%Y-%m-%d', trim(tanggal_berangkat))
    else
        null
    end as tanggal_berangkat,

    -- FORMAT JAM BERANGKAT
    case
      when regexp_contains(trim(jam_berangkat), r'^\d{1,2}:\d{2}:\d{2}$')
      then parse_time('%H:%M:%S', trim(jam_berangkat))

      when regexp_contains(trim(jam_berangkat), r'^\d{1,2}:\d{2}$')
      then parse_time('%H:%M', trim(jam_berangkat))

      when regexp_contains(trim(jam_berangkat), r'^\d{1,2}\.\d{2}$')
      then parse_time('%H.%M', trim(jam_berangkat))
    else
        null
    end as jam_berangkat,

    -- FORMAT JAM TIBA
    case
      when regexp_contains(trim(jam_tiba), r'^\d{1,2}:\d{2}:\d{2}$')
      then parse_time('%H:%M:%S', trim(jam_tiba))

      when regexp_contains(trim(jam_tiba), r'^\d{1,2}:\d{2}$')
      then parse_time('%H:%M', trim(jam_tiba))

      when regexp_contains(trim(jam_tiba), r'^\d{1,2}\.\d{2}$')
      then parse_time('%H.%M', trim(jam_tiba))
    else
        null
    end as jam_tiba,

    -- SET NULL KELAS
    case
      when lower(trim(kelas)) in ("nan", "null", "n/a", "none", "-") 
      then null
    else
      initcap(trim(kelas))
    end kelas,
    trim(regexp_replace(harga_tiket,r"\.|Rp","")) harga_tiket,

    -- SET NULL STATUS
    case
      when lower(trim(status)) in ("nan", "null", "n/a", "none", "-") 
      then null
    else
      initcap(trim(status))
    end status,
  from `root-rarity-502614-g2.portofolio.jadwal_kereta_dirty`
 ),
 new_tipe_data as(
  select
    id_jadwal,
    nama_kereta,
    nomor_kereta,
    stasiun_asal,
    stasiun_tujuan,
    cast(tanggal_berangkat as date) tanggal_berangkat,
    cast(jam_berangkat as time) jam_berangkat,
    cast(jam_tiba as time) jam_tiba,
    kelas,
    cast(harga_tiket as int64) harga_tiket,
    status
  from new_table
 ),
 clean_table as(
  select
    id_jadwal,
    coalesce(nama_kereta, 'UNKNOWN') nama_kereta,
    coalesce(nomor_kereta, 'UNKNOWN') nomor_kereta,
    coalesce(stasiun_asal, 'UNKNOWN') stasiun_asal,
    coalesce(stasiun_tujuan,'UNKNOWN') stasiun_tujuan,
    tanggal_berangkat,
    jam_berangkat,
    jam_tiba,
    coalesce(kelas, 'UNKNOWN') kelas,
    harga_tiket,
    coalesce(status, "Waiting") status
  FROM new_tipe_data
 )

SELECT
  *
FROM clean_table
