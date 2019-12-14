// Initialize
const allCardsHeaders = document.getElementsByClassName("cardHeader");
for (header of allCardsHeaders) {
    header.addEventListener("click", clickCard);
}

function clickCard(e) {
    this.parentElement.classList.toggle('cardActive');
}