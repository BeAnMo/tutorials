window.onload = main;



function main(){
    console.log('loaded: app.js');
    var btn = document.getElementById('info');
    var display = document.getElementById('display');
    var get = getData.bind(display);

    btn.addEventListener('click', get);
}

function getData(event){
    var req = new XMLHttpRequest();

    req.open('GET', './info', true);
    req.responseType = 'json';
    //req.responseType = 'text';
    
    req.addEventListener('load', function(){
	console.log('status: ' + req.status);
	console.log(req.response);

	displayData(display, req.response);
    });

    req.send(null);
}

function displayData(disp, res){
    if(res === null){
	disp.textContent = "No JSON output";
    } else {
	disp.textContent = "JSON: " + res['hello'];
    }
}
