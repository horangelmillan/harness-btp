using { qunit.books as db } from '../db/schema';

// Sin @requires: fixture local para QUnit/OPA5 en navegador sin login.
// La autoridad de tipos/existencia la impone el runtime (400/404).
service CatalogService {
  entity Books as projection on db.Books;
}
