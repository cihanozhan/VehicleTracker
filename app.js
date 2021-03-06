'use strict';

var express = require('express');
var path = require('path');
var favicon = require('static-favicon');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var session = require('express-session');
var flash = require('connect-flash');
var less = require('less-middleware');
var passport = require('passport');

var rekuire = require('rekuire');
var logger = rekuire('logger');
var keysConfig = rekuire('keys.config');
var authConfiguration = rekuire('authConfiguration');
var roleConfiguration = rekuire('roleConfiguration');

var routes = require('./src/routes/index');
var admin = require('./src/routes/admin');
var register = require('./src/routes/register');
var login = require('./src/routes/login');
var logout = require('./src/routes/logout');
var profile = require('./src/routes/profile');
var manager = require('./src/routes/manager');
var vehicle = require('./src/routes/vehicle');
var driver = require('./src/routes/driver');
var jobOffers = require('./src/routes/jobOffers');
var membershipTest = require('./tests/membershipTestRoute');

var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(favicon());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(cookieParser());

app.use(session({
	secret: keysConfig.cookieSessionSecret,
	key: 'vt-session'
}));
app.use(flash());

passport.use(authConfiguration.passportStrategy);
app.use(passport.initialize());

passport.serializeUser(authConfiguration.serializeUser);
passport.deserializeUser(authConfiguration.deserializeUser);
app.use(passport.session());

app.use(roleConfiguration.middleware());

app.use(less({
	src: path.join(__dirname, 'public'),
	paths: [__dirname]
}));

app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/admin', admin);
app.use('/register', register);
app.use('/login', login);
app.use('/logout', logout);
app.use('/profile', profile);
app.use('/a', membershipTest);
app.use('/m', manager);
app.use('/v', vehicle);
app.use('/d', driver);
app.use('/jobOffers', jobOffers);

/// catch 404 and forwarding to error handler
app.use(function (req, res, next) {
	var err = new Error('Not Found');
	err.status = 404;
	next(err);
});

/// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
	app.use(function (err, req, res, next) {
		res.status(err.status || 500);
		res.render('error', {
			message: err.message,
			error: err
		});
	});
}

// production error handler
// no stacktraces leaked to user
app.use(function (err, req, res, next) {
	res.status(err.status || 500);
	res.render('error', {
		message: err.message,
		error: {}
	});
});

module.exports = app;