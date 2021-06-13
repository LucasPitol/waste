import { Routes, RouterModule } from "@angular/router";
import { LoginComponent } from "./pages/login/login.component";
import { PaymentComponent } from "./pages/payment/payment.component";



const appRoutes: Routes = [
    { path: 'login', component: LoginComponent },
    { path: 'payment', component: PaymentComponent },
    { path: '**', redirectTo: 'login' }
]

export const routing = RouterModule.forRoot(appRoutes);
