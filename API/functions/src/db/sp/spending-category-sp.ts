import { SpendingCategory } from "../../models/spending-category";
import { supabase } from "../supabase";

interface SupabaseSpendingCategoryRow {
    id: string;
    display_name_pt?: string;
    display_name_en?: string;
    value: string;
}

export class SpendingCategorySP {
    tableName = "spending_categories";

    async createNewSpendingCategory(name: string, value: string): Promise<string> {
        const { data, error } = await supabase
            .from(this.tableName)
            .insert({
                display_name_pt: name,
                value: value,
            })
            .select('id')
            .single();

        if (error) {
            throw new Error(`Error creating spending category: ${error.message}`);
        }

        return data.id;
    }

    async getByValue(value: string): Promise<SpendingCategory | null> {
        const { data, error } = await supabase
            .from(this.tableName)
            .select('*')
            .eq('value', value)
            .single();

        if (error) {
            if (error.code === 'PGRST116') return null; // Not found
            throw new Error(`Error fetching spending category by value: ${error.message}`);
        }

        return this.convertToSpendingCategoryModel(data);
    }

    async getSpendingCategories(): Promise<SpendingCategory[]> {
        const { data, error } = await supabase
            .from(this.tableName)
            .select('*')
            .order('display_name_pt', { ascending: true });

        if (error) {
            throw new Error(`Error fetching spending categories: ${error.message}`);
        }

        if (!data || data.length === 0) {
            return [];
        }

        return data.map(row => this.convertToSpendingCategoryModel(row));
    }

    // Helper method to convert Supabase data to SpendingCategory model
    private convertToSpendingCategoryModel(categoryData: SupabaseSpendingCategoryRow): SpendingCategory {
        // Create a mock DocumentSnapshot-like object for the existing SpendingCategory constructor
        const mockDoc = {
            id: categoryData.id,
            data: () => ({
                displayNamePt: categoryData.display_name_pt,
                value: categoryData.value,
                creationDate: new Date(),
                lastUpdate: new Date()
            })
        };

        return new SpendingCategory(mockDoc as any);
    }
}
