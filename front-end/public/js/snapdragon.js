var showingItemId = 0
function showFullItem(itemId) {
	// Turn off the item that was already showing
	if(showingItemFull = document.getElementById("full" + showingItemId)) {
		showingItemFull.style.display = "none"
	}
	if(showingItemBlurb = document.getElementById("blurb" + showingItemId)) {
		showingItemBlurb.style.display = "block"
	}
	
	// Turn on the item user wants to show now
	document.getElementById("blurb" + itemId).style.display = "none"
	document.getElementById("full" + itemId).style.display = "block"

	showingItemId = itemId	
}

function highlightItem(itemId) {
	document.getElementById("item" + itemId).style.background = "#EDE8E8"
}

function normalizeItem(itemId) {
	document.getElementById("item" + itemId).style.background = ""	
}