var argv = require('yargs').argv,
    exec = require('child_process').exec,
    gulp = require('gulp'),
    rename = require('gulp-rename'),
    uglify = require('gulp-uglify'),
    wrap = require("gulp-wrap");

var BUILD_DIR = './build/',
    CONFIG_DIR = './config/',
    TPL_DIR = './templates/',
    CONTRACT = 'contract.json',
    MAIN_SOL = 'main.sol',
    ENV_FILE = CONFIG_DIR + 'env'
    ENV_FILE_TPL = ENV_FILE + '.tpl',
    GENESIS_FILE = CONFIG_DIR + 'genesis.json',
    GENESIS_FILE_TPL = GENESIS_FILE + '.tpl',
    CREATE_CONTRACT_TPL = 'create_contract.js';

gulp.task('install', function () {
  gulp.src(ENV_FILE_TPL)
    .pipe(rename(ENV_FILE))
    .pipe(gulp.dest('.'));
  gulp.src(GENESIS_FILE_TPL)
    .pipe(rename(GENESIS_FILE))
    .pipe(gulp.dest('.'));
  exec('touch ' + CONFIG_DIR + 'password');
});

gulp.task('default', ['new-contract-min']);


gulp.task('build-contract', function (cb) {
  var cmd = 'solc ' + MAIN_SOL + ' --combined-json binary,json-abi > ' + BUILD_DIR + CONTRACT;
  exec(cmd, function (err, stdout, stderr) {
    console.log(cmd);
    if (stdout) console.log(stdout);
    if (stderr) console.error(stderr);
    cb(err);
  });
});

gulp.task('new-contract', ['build-contract'], function () {
  gulp.src(BUILD_DIR + CONTRACT)
    .pipe(wrap({src: TPL_DIR + CREATE_CONTRACT_TPL}, {gas: 1000000}))
    .pipe(rename(CREATE_CONTRACT_TPL))
    .pipe(gulp.dest(BUILD_DIR));
});

gulp.task('new-contract-min', ['new-contract'], function () {
  gulp.src(BUILD_DIR + CREATE_CONTRACT_TPL)
    .pipe(uglify())
    .pipe(rename('create_contract.min.js'))
    .pipe(gulp.dest(BUILD_DIR));
});

gulp.task('mongo-contract', ['build-contract'], function () {
  gulp.src(BUILD_DIR + CONTRACT)
    .pipe(wrap({src: 'templates/mongo_update.js'}, {address: argv.a}))
    .pipe(rename('mongo_update.js'))
    .pipe(gulp.dest(BUILD_DIR));
});
