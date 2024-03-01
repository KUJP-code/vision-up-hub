import { Controller } from "@hotwired/stimulus";

//Method for toggling between language locales
export default class extends Controller{
    toggleLocale(event){
        event.preventDefault();
        //determine current and new locales
        let currentLocale = window.location.search.includes('locale=en') ? "en" : "ja";
        let newLocale = currentLocale === "en" ? "ja" : "en";
        //make new url
        let newUrl = window.location.href.replace(`locale=${currentLocale}`, `locale=${newLocale}`);
        //redirect
        window.location.href = newUrl;
    }
}