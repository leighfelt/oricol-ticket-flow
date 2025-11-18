import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Database, CheckCircle2, AlertCircle, Loader2, RefreshCw } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { Alert, AlertDescription } from "@/components/ui/alert";

interface MigrationStatus {
  filename: string;
  applied: boolean;
  appliedAt?: string;
}

export const MigrationManager = () => {
  const [migrations, setMigrations] = useState<MigrationStatus[]>([]);
  const [loading, setLoading] = useState(false);
  const [applying, setApplying] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    checkMigrationStatus();
  }, []);

  const checkMigrationStatus = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke('check-migrations');
      
      if (error) throw error;
      
      setMigrations(data.migrations || []);
    } catch (error: any) {
      console.error('Failed to check migrations:', error);
      toast({
        title: "Error",
        description: "Failed to check migration status. See console for details.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const applyPendingMigrations = async () => {
    setApplying(true);
    try {
      const { data, error } = await supabase.functions.invoke('apply-migrations');
      
      if (error) throw error;

      toast({
        title: "Success",
        description: `Applied ${data.appliedCount} migration(s) successfully.`,
      });

      // Refresh status
      await checkMigrationStatus();
    } catch (error: any) {
      console.error('Failed to apply migrations:', error);
      toast({
        title: "Error",
        description: error.message || "Failed to apply migrations.",
        variant: "destructive",
      });
    } finally {
      setApplying(false);
    }
  };

  const pendingCount = migrations.filter(m => !m.applied).length;
  const appliedCount = migrations.filter(m => m.applied).length;

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Database className="h-5 w-5 text-primary" />
            <div>
              <CardTitle>Database Migrations</CardTitle>
              <CardDescription>Automatically sync SQL changes from GitHub</CardDescription>
            </div>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={checkMigrationStatus}
            disabled={loading}
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Stats */}
        <div className="flex gap-4">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-green-500" />
            <span className="text-sm">
              <strong>{appliedCount}</strong> Applied
            </span>
          </div>
          <div className="flex items-center gap-2">
            <AlertCircle className="h-4 w-4 text-orange-500" />
            <span className="text-sm">
              <strong>{pendingCount}</strong> Pending
            </span>
          </div>
        </div>

        {/* Pending migrations alert */}
        {pendingCount > 0 && (
          <Alert>
            <AlertCircle className="h-4 w-4" />
            <AlertDescription className="flex items-center justify-between">
              <span>
                {pendingCount} new migration{pendingCount > 1 ? 's' : ''} detected from GitHub.
              </span>
              <Button
                size="sm"
                onClick={applyPendingMigrations}
                disabled={applying}
              >
                {applying ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Applying...
                  </>
                ) : (
                  `Apply ${pendingCount} Migration${pendingCount > 1 ? 's' : ''}`
                )}
              </Button>
            </AlertDescription>
          </Alert>
        )}

        {/* Migration list */}
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : migrations.length === 0 ? (
          <p className="text-sm text-muted-foreground text-center py-4">
            No migrations found
          </p>
        ) : (
          <div className="space-y-2 max-h-[300px] overflow-y-auto">
            {migrations.map((migration) => (
              <div
                key={migration.filename}
                className="flex items-center justify-between p-3 rounded-lg border bg-card hover:bg-accent/50 transition-colors"
              >
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  {migration.applied ? (
                    <CheckCircle2 className="h-4 w-4 text-green-500 flex-shrink-0" />
                  ) : (
                    <AlertCircle className="h-4 w-4 text-orange-500 flex-shrink-0" />
                  )}
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-mono truncate" title={migration.filename}>
                      {migration.filename}
                    </p>
                    {migration.appliedAt && (
                      <p className="text-xs text-muted-foreground">
                        Applied {new Date(migration.appliedAt).toLocaleString()}
                      </p>
                    )}
                  </div>
                </div>
                <Badge variant={migration.applied ? "default" : "secondary"}>
                  {migration.applied ? "Applied" : "Pending"}
                </Badge>
              </div>
            ))}
          </div>
        )}

        {/* Info text */}
        <p className="text-xs text-muted-foreground">
          Migrations are automatically detected when you push SQL changes to GitHub. 
          Click "Apply Migrations" to sync your database with the latest schema changes.
        </p>
      </CardContent>
    </Card>
  );
};
