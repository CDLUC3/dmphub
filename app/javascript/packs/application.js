// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");
require("jquery");

require("../utils/addSection");
require("../utils/debouncer");
require("../utils/forms");
require("../utils/typeahead");

require("../utils/accordion");
require("../utils/ethics");
require("../utils/other");
require("../utils/progress");
require("../utils/spinner");
require("../utils/table");

require("../views/data_management_plans/newEdit");
require("../views/data_management_plans/show");
require("../views/shared/form");
require("../views/users/signUp");

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

/* TODO: temporary compiled JS until the ui library is inteegrated */
/*
"use strict";if(document.querySelector(".c-progress"))for(var steps=document.querySelectorAll(".c-progress li"),i=0;i<steps.length&&!steps[i].hasAttribute("aria-current");i++)steps[i].classList.add("completed"),steps[i].insertAdjacentHTML("afterbegin","<span>Completed step: </span>");
*/
