const toggle = document.querySelector(".nav-toggle");
const nav = document.querySelector("#site-nav");

if (toggle && nav) {
  toggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    toggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.addEventListener("click", (event) => {
    if (event.target instanceof HTMLAnchorElement) {
      nav.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
    }
  });
}

const signupForm = document.querySelector(".signup-form");

if (signupForm) {
  signupForm.addEventListener("submit", (event) => {
    event.preventDefault();
    alert("报名意向已记录。请联系王子加入河南人在广州老乡社群。");
  });
}
