

// constants
// these must remain 100 for the puzzle piece path stuff to work out
	const piecewidth = 100;
	const pieceheight = 100;
	const canvasHeightPipeline = 100
	const canvasHeightInteractive = 300;
	const canvasHeightChooser = 300;
	// we should set canvas width appropriately
	let totalCanvasWidth = 1000;
	const totalCanvasHeight = canvasHeightInteractive + canvasHeightChooser;

	// The set of languages and their properties
	const srcLanguageGroups = {
		frontend:[{langid:'sql', label:'SQL'}, {langid:'oql', label:'OQL'}],
        intermediate:[{langid:'nrae', label:'NRAenv'}, {langid:'nrc', label:'NNRC'}],
        backend:[{langid:'js', label:'javascript'}, {langid:'cloudant', label:'Cloudant'}]};


	function toSrcLangDescript(color, sides) {
		return function(group) {
			return {langid:group.langid, label:group.label, fill:color, sides:sides};
		}
	}
	
	function getSrcLangDescripts(langGroups) {
		let ret = [];
		ret.push(langGroups.frontend.map(toSrcLangDescript('#33cc33', {right:-1})));
		ret.push(langGroups.intermediate.map(toSrcLangDescript('#6699ff', {left: 1, right:-1})))
		ret.push(langGroups.backend.map(toSrcLangDescript('#ff3300', {left: 1})));

		return ret;
	}

	// the boundary between the interactive and the selections
	let separatorLine = new fabric.Line([ 0, canvasHeightInteractive, totalCanvasWidth, canvasHeightInteractive], { stroke: '#ccc', selectable: false });

	function updateCanvasWidth(canvas, newWidth) {
		totalCanvasWidth = newWidth;
		canvas.setWidth(newWidth);
		separatorLine.set('x2', newWidth);
	}

	function ensureCanvasWidth(canvas, lastpiece) {
		const newwidth = (lastpiece+1)*piecewidth;
		if(newwidth > totalCanvasWidth) {
			updateCanvasWidth(canvas, newwidth);
		}
	}

// based on code from https://www.codeproject.com/articles/395453/html-jigsaw-puzzle
	function getMask(tileRatio, topTab, rightTab, bottomTab, leftTab) {

		var curvyCoords = [ 0, 0, 35, 15, 37, 5, 37, 5, 40, 0, 38, -5, 38, -5,
				20, -20, 50, -20, 50, -20, 80, -20, 62, -5, 62, -5, 60, 0, 63,
				5, 63, 5, 65, 15, 100, 0 ];
		const tileWidth = 100;
		const tileHeight = 100;
		var mask = "";
		var leftx = -4;
		var topy = 0;
		var rightx = leftx + tileWidth;
		var bottomy = topy + tileHeight;

		mask += "M" + leftx + "," + topy;

		//Top
		for (var i = 0; i < curvyCoords.length / 6; i++) {
			mask += "C";
			mask += leftx + curvyCoords[i * 6 + 0] * tileRatio;
			mask += ",";
			mask += topy + topTab * curvyCoords[i * 6 + 1] * tileRatio;
			mask += ",";
			mask += leftx + curvyCoords[i * 6 + 2] * tileRatio;
			mask += ",";
			mask += topy + topTab * curvyCoords[i * 6 + 3] * tileRatio;
			mask += ",";
			mask += leftx + curvyCoords[i * 6 + 4] * tileRatio;
			mask += ",";
			mask += topy + topTab * curvyCoords[i * 6 + 5] * tileRatio;
		}
		//Right
		for (var i = 0; i < curvyCoords.length / 6; i++) {
			mask += "C";
			mask += rightx - rightTab * curvyCoords[i * 6 + 1] * tileRatio;
			mask += ",";
			mask += topy + curvyCoords[i * 6 + 0] * tileRatio;
			mask += ",";
			mask += rightx - rightTab * curvyCoords[i * 6 + 3] * tileRatio;
			mask += ",";
			mask += topy + curvyCoords[i * 6 + 2] * tileRatio;
			mask += ",";
			mask += rightx - rightTab * curvyCoords[i * 6 + 5] * tileRatio;
			mask += ",";
			mask += topy + curvyCoords[i * 6 + 4] * tileRatio;
		}

		//Bottom
		for (var i = 0; i < curvyCoords.length / 6; i++) {
			mask += "C";
			mask += rightx - curvyCoords[i * 6 + 0] * tileRatio;
			mask += ",";
			mask += bottomy - bottomTab*curvyCoords[i * 6 + 1] * tileRatio;
			mask += ",";
			mask += rightx - curvyCoords[i * 6 + 2] * tileRatio;
			mask += ",";
			mask += bottomy - bottomTab * curvyCoords[i * 6 + 3] * tileRatio;
			mask += ",";
			mask += rightx - curvyCoords[i * 6 + 4] * tileRatio;
			mask += ",";
			mask += bottomy - bottomTab * curvyCoords[i * 6 + 5] * tileRatio;
		}

		
		//Left
		for (var i = 0; i < curvyCoords.length / 6; i++) {
			mask += "C";
			mask += leftx + leftTab * curvyCoords[i * 6 + 1] * tileRatio;
			mask += ",";
			mask += bottomy - curvyCoords[i * 6 + 0] * tileRatio;
			mask += ",";
			mask += leftx + leftTab * curvyCoords[i * 6 + 3] * tileRatio;
			mask += ",";
			mask += bottomy - curvyCoords[i * 6 + 2] * tileRatio;
			mask += ",";
			mask += leftx + leftTab * curvyCoords[i * 6 + 5] * tileRatio;
			mask += ",";
			mask += bottomy - curvyCoords[i * 6 + 4] * tileRatio;
		}

		return mask;
	}

// The class for a puzzle piece object
var PuzzlePiece:new(args:any)=>any = <any>fabric.util.createClass(fabric.Rect, {

  type: 'puzzlePiece',

  initialize: function(options) {
    options || (options = { });
	options.width = piecewidth;
	options.height = pieceheight;
    this.callSuper('initialize', options);
    this.set('label', options.label || '');

	const puzzleSides = options.sides || {};
	const puzzleLeft = puzzleSides.left || 0;
	const puzzleRight = puzzleSides.right || 0;
	const puzzleTop = puzzleSides.top || 0;
	const puzzleBottom = puzzleSides.bottom || 0;

	var path = new fabric.Path(getMask(1, puzzleTop, puzzleRight, puzzleBottom, puzzleLeft));
	path.centeredScaling = true;
    path.scale(1);

    //path.selectable = true;
    path.originX = 'center';
    path.originY = 'center';
	this.puzzlePath = path;
	this.set('clipTo', function (ctxt) {
		const p:any = path;
	 	p._render(ctxt);
	});

  },

  toObject: function() {
    return fabric.util.object.extend(this.callSuper('toObject'), {
      label: this.get('label')
    });
  },

  _render: function(ctx) {
    this.callSuper('_render', ctx);
    ctx.font = '30px Helvetica';
    ctx.fillStyle = '#333';
	ctx.textAlign='center';
	ctx.textStyle='bold';
    ctx.fillText(this.label, -this.width/2+50, -this.height/2 + 30);
  }
});

var sourcePieces = {};
var placedPieces = [];

function mkSourcePiece(options) {

	var piece = new PuzzlePiece({
		left : (options.col || 0)*(piecewidth + 30) + 20,
		top : canvasHeightInteractive + ((options.row || 0)*(pieceheight+30)) + 10,
		fill : options.fill || 'purple',
		label : options.label,
		sides : options.sides || {},
		hasControls : false,
		hasBorders : false
	});
	piece.isSourcePiece = true;
	// TODO: work on getting things to move out of the way
	// track what we were over last / are over now
	// and use that to track what is going on
	// once that is working, change the code to move things over 
	// to use animations to look smooth

	// TODO: when things move, they sometimes become deselected ( / in the wrong place? check!)
	
	function mousedownfunc() {
		piece.set({
			opacity:.5
		});
		if(piece.isSourcePiece) {
			// create a new copy of this piece
			var copyOfSelf = mkSourcePiece(options);
			// and make it the new "canonical" source piece
			sourcePieces[options.pieceID] = copyOfSelf;
			piece.canvas.add(copyOfSelf);

			// now make this piece into a non source piece
			piece.isSourcePiece = false;
		} else {
			// update the placed grid
			const topentry = Math.round(piece.top / pieceheight);
			const leftentry = Math.round(piece.left / piecewidth);
			
			delete placedPieces[topentry][leftentry];
		}
	};

	piece.on('mousedown', mousedownfunc);
	piece.on('mouseup', function() {
		piece.set({
			opacity:1
		});

		const topentry = Math.round(piece.top / pieceheight);
		const leftentry = Math.round(piece.left / piecewidth);

		// snap to grid
		piece.set({
			left: leftentry * piecewidth,
			top: topentry * pieceheight
		});
		piece.setCoords();
	
		if(!piece.isSourcePiece) {
			if(piece.top >= canvasHeightInteractive) {
				piece.canvas.remove(piece);
			}

		
			
			// update the placed grid
			if('movePlace' in piece) {
				// finalize the moved pieces in their new positions
				const prow = placedPieces[topentry];
				if(! (prow === undefined)) {
					let curleft = leftentry;
					let curleftval = prow[leftentry];
					while(! (curleftval === undefined)) {
						let nextleft = curleft+1;
						let nextleftval = prow[nextleft];

						prow[nextleft] = curleftval;
						curleft = nextleft;
						curleftval = nextleftval;
					}
					ensureCanvasWidth(piece.canvas, curleft);
					prow[leftentry] = undefined;
				}
				delete piece['movePlace'];
			}
			if(topentry >= placedPieces.length || placedPieces[topentry] === undefined) {
				placedPieces[topentry] = [];
			}
			const topplaces = placedPieces[topentry];
			if(leftentry >= topplaces.length || topplaces[leftentry] === undefined) {
				topplaces[leftentry] = piece;
			}
		}
//		piece.canvas.renderAll();
	});
	piece.on('moving', function() {
		const topentry = Math.round(piece.top / pieceheight);
		const leftentry = Math.round(piece.left / piecewidth);

		if('movePlace' in piece) {
			if(piece.movePlace.left == leftentry && piece.movePlace.top == topentry) {
				// still over the same grid spot
				return;
			}
			// otherwise, we moved.  We need to put back anything we moved out of the way
			const oldtop = piece.movePlace.top;
			const prow = placedPieces[oldtop];
			if(! (prow === undefined)) {
				var oldleft = piece.movePlace.left;
				while(true) {
					let mp = prow[oldleft];
					if(mp === undefined) {
						break;
					}
					mp.left = oldleft*piecewidth;
					mp.setCoords();
					oldleft = oldleft + 1;
				}
			}
		}
		piece.movePlace = {top:topentry, left:leftentry};
		const prow = placedPieces[topentry];
		if(! (prow === undefined)) {
			var curleft = leftentry;
			while(true) {
				let mp = prow[curleft];
				if(mp === undefined) {
					break;
				}
				mp.left = (curleft+1)*piecewidth;
				mp.setCoords();
				curleft = curleft + 1;
			}
		}
	});
	return piece;
}



function init() {
    var canvas = new fabric.Canvas('main-canvas');
	canvas.hoverCursor = 'pointer';
	canvas.selection = false;

	// canvas.on('selection:created', function (event) {
	// 	canvas.getActiveGroup().set({hasControls : false});
	// });

	// canvas.on('object:moving', function (event) {
	// 	const piece = event.target;
	// 	piece.set({
	// 	left: Math.round(piece.left / piecewidth) * piecewidth,
	// 	top: Math.round(piece.top / pieceheight) * pieceheight
	// 	});
	// });
	
	canvas.add(separatorLine);
	separatorLine.set('visible', true);
	// disable group selection
	//canvas.selection = false;

	// create the start piece
	var startPiece = new PuzzlePiece({
		left : 10,
		top : canvasHeightPipeline,
		fill : 'green',
		label : 'start',
		sides : {right:-1},
		hasControls : false,
		selectable : false,
		evented : false
	});
	canvas.add(startPiece);

	const srcLangDescripts = getSrcLangDescripts(srcLanguageGroups);
	// create the list of languages that can be dragged onto the canvas
	for(var srcrow=0; srcrow < srcLangDescripts.length; srcrow++) {
		let rowelem = srcLangDescripts[srcrow];
		if(rowelem == null) {
			continue;
		}
		for(var srccol=0; srccol < rowelem.length; srccol++) {
			let colelem = rowelem[srccol];
			if(colelem == null) {
				continue;
			}

			colelem.row = srcrow;
			colelem.col = srccol;
			const pieceID = srcrow*srccol;
			colelem.pieceID = pieceID;
			let piece = mkSourcePiece(colelem);
			sourcePieces[pieceID] = piece;
			canvas.add(piece);
		}
	}

    // // create grid
    // for (var i = 0; i < (600 / grid); i++) {
    //   canvas.add(new fabric.Line([ i * grid, 0, i * grid, 600], { stroke: '#ccc', selectable: false }));
    //   canvas.add(new fabric.Line([ 0, i * grid, 600, i * grid], { stroke: '#ccc', selectable: false }))
    // }

	// sourceCollection[1].set({
	// 	clipTo: function (ctxt) {
	// 		path._render(ctxt);
	// 	}
	// });
	canvas.renderAll();
}