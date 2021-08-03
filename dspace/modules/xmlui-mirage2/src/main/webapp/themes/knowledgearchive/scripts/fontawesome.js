import { library, dom } from '@fortawesome/fontawesome-svg-core'
import { faAt } from '@fortawesome/free-solid-svg-icons'
import { faFacebookF, faTwitter, faLinkedinIn, faWhatsapp, faOrcid } from '@fortawesome/free-brands-svg-icons'

// Add solid icons to our library
library.add(faAt)

// Add brand icons to our library
library.add(faFacebookF, faTwitter, faLinkedinIn, faWhatsapp, faOrcid)

// Replace any existing <i> tags with <svg> and set up a MutationObserver to
// continue doing this as the DOM changes.
dom.watch()
