import { Router } from '@angular/router';

export const Utils =
{
    gotoUserVerification: function(uid: string, router: Router) 
    {
        router.navigate(["verification/" + uid]);
    },

    goHome: function(router: Router)
	{
		router.navigate(["home"])
	},
}