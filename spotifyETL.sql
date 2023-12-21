CREATE OR REPLACE DATABASE spotify_etl_project;

CREATE OR REPLACE STORAGE INTEGRATION spotify_s3_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = ''
    STORAGE_ALLOWED_LOCATIONS = ('s3://spotify-etl-project-shweta')
     COMMENT = 'creating connection to s3'

DESC INTEGRATION spotify_s3_int;


CREATE OR REPLACE FILE FORMAT csv_file_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';


CREATE OR REPLACE TABLE tblAlbum(
  album_id varchar,
  album_name varchar,
  album_release_date date,
  album_total_tracks int,
  album_url varchar
);

CREATE OR REPLACE TABLE tblArtist(
  artist_id varchar,
  artist_name varchar,
  external_url varchar
);

CREATE OR REPLACE TABLE tblSongs(
  song_id varchar,
  song_name varchar,
  song_duration int,
  song_url varchar,
  song_popularity int,
  song_added datetime,
  album_id varchar,
  artist_id varchar
)

CREATE OR REPLACE STAGE spotify_s3_int_stage
  URL='s3://spotify-etl-project-shweta/transformed_data/'  
  STORAGE_INTEGRATION = spotify_s3_int
  FILE_FORMAT = csv_file_format;

DESC STAGE spotify_s3_int_stage;
LIST @spotify_s3_int_stage;


COPY INTO tblAlbum FROM 
  @spotify_s3_int_stage/album_data/;

SELECT * FROM tblalbum;  



COPY INTO tblArtist FROM 
  @spotify_s3_int_stage/artist_data/;

SELECT * FROM tblArtist;  



COPY INTO tblSongs FROM 
  @spotify_s3_int_stage/songs_data/;

SELECT * FROM tblSongs;  





CREATE OR REPLACE SCHEMA SPOTIFY_ETL_PROJECT.pipes;

CREATE OR REPLACE pipe SPOTIFY_ETL_PROJECT.pipes.album_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO SPOTIFY_ETL_PROJECT.PUBLIC.tblAlbum
  FROM @SPOTIFY_ETL_PROJECT.PUBLIC.spotify_s3_int_stage/album_data/;

DESC pipe SPOTIFY_ETL_PROJECT.pipes.album_pipe;


CREATE OR REPLACE pipe SPOTIFY_ETL_PROJECT.pipes.artist_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO SPOTIFY_ETL_PROJECT.PUBLIC.tblArtist
  FROM @SPOTIFY_ETL_PROJECT.PUBLIC.spotify_s3_int_stage/artist_data/;

DESC pipe SPOTIFY_ETL_PROJECT.pipes.artist_pipe;


CREATE OR REPLACE pipe SPOTIFY_ETL_PROJECT.pipes.songs_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO SPOTIFY_ETL_PROJECT.PUBLIC.tblSongs
  FROM @SPOTIFY_ETL_PROJECT.PUBLIC.spotify_s3_int_stage/songs_data/;

DESC pipe SPOTIFY_ETL_PROJECT.pipes.songs_pipe;



SELECT * FROM SPOTIFY_ETL_PROJECT.PUBLIC.tblalbum;  
SELECT * FROM SPOTIFY_ETL_PROJECT.PUBLIC.tblArtist; 
SELECT * FROM SPOTIFY_ETL_PROJECT.PUBLIC.tblSongs;  



