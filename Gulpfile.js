var argv = require('yargs').argv,
    exec = require('child_process').exec,
    gulp = require('gulp'),
    rename = require('gulp-rename'),
    wrap = require("gulp-wrap");

var BUILD_DIR = './build/',
    CONFIG_DIR = './config/',
    CONTRACT = 'contract_data.json',
    MAIN_SOL = 'main.sol';

gulp.task('install', function () {
  exec('date +%s | shasum | base64 | head -c 32 > ' + CONFIG_DIR + 'password');
});

gulp.task('default', ['new-contract']);


gulp.task('build-contract', function (cb) {
  var cmd = 'solc ' + MAIN_SOL + ' --combined-json bin,abi > ' + BUILD_DIR + CONTRACT;
  exec(cmd, function (err, stdout, stderr) {
    console.log(cmd);
    if (stdout) console.log(stdout);
    if (stderr) console.error(stderr);
    cb(err);
  });
});

gulp.task('new-contract', ['build-contract'], function () {
  gulp.src(BUILD_DIR + CONTRACT)
    .pipe(wrap({src: 'templates/create_contract.js'}, {gas: 2000000}))
    .pipe(rename('create_contract.js'))
    .pipe(gulp.dest(BUILD_DIR));
});

gulp.task('contract-json', ['build-contract'], function () {
  gulp.src(BUILD_DIR + CONTRACT)
    .pipe(wrap({src: 'templates/contract.json'}, {address: argv.a}))
    .pipe(rename('contract.json'))
    .pipe(gulp.dest(BUILD_DIR));
});
