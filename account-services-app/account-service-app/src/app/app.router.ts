import { Routes, RouterModule } from "@angular/router";
import { DeleteUserComponent } from './pages/delete-user/delete-user.component';
import { HomeComponent } from './pages/home/home.component';


const appRoutes: Routes = [
    { path: 'home', component: HomeComponent },
    { path: 'verification/:uid', component: DeleteUserComponent },
    { path: '**', redirectTo: 'home' }
]

export const routing = RouterModule.forRoot(appRoutes);
