var exec = require('child_process').exec,
    gulp = require('gulp'),
    rename = require('gulp-rename'),
    wrap = require("gulp-wrap");

var BUILD_DIR = './build/',
    CONFIG_DIR = './config/',
    CONTRACT = 'contract.json',
    MAIN_SOL = 'main.sol',
    ENV_FILE = CONFIG_DIR + 'env'
    ENV_FILE_TPL = ENV_FILE + '.tpl',
    GENESIS_FILE = CONFIG_DIR + 'genesis.json',
    GENESIS_FILE_TPL = GENESIS_FILE + '.tpl';

gulp.task('install', function () {
  gulp.src(ENV_FILE_TPL)
    .pipe(rename(ENV_FILE))
    .pipe(gulp.dest('.'));
  gulp.src(GENESIS_FILE_TPL)
    .pipe(rename(GENESIS_FILE))
    .pipe(gulp.dest('.'));
});

gulp.task('default', ['new-contract']);


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
    .pipe(wrap({src: 'templates/create_contract.js'}, {gas: 700000}))
    .pipe(rename('create_contract.js'))
    .pipe(gulp.dest(BUILD_DIR));
});
