const repo_dest = "/opt/mkdocs";

const http = require('http');
const crypto = require('crypto');
const exec = require('child_process').exec;

http.createServer(function (req, res) {
    req.on('data', function(chunk) {
        let sig = "sha1=" + crypto.createHmac('sha1', webhook_secret).update(chunk.toString()).digest('hex');

        if (req.headers['x-hub-signature'] == sig) {
            exec('cd ' + repo_dest + ' && git pull' + ' && mkdocs build');
        }
    });

    res.end();
}).listen(8080);