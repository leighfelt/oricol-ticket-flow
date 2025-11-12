import { useState, useEffect } from "react";
import { useSearchParams } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { CheckCircle2, XCircle, Loader2, ArrowLeft } from "lucide-react";
import { Link } from "react-router-dom";
import oricolLogo from "@/assets/oricol-logo.png";

export default function ProviderConfirm() {
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  
  const [loading, setLoading] = useState(false);
  const [confirmed, setConfirmed] = useState(false);
  const [error, setError] = useState("");
  const [providerName, setProviderName] = useState("");
  const [notes, setNotes] = useState("");
  const [emailDetails, setEmailDetails] = useState<any>(null);

  const handleConfirm = async () => {
    if (!token) {
      setError("Invalid confirmation link");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const { data, error: confirmError } = await supabase.functions.invoke('confirm-provider-task', {
        body: { 
          token,
          providerName: providerName || undefined,
          notes: notes || undefined
        }
      });

      if (confirmError) throw confirmError;

      if (data?.success) {
        setConfirmed(true);
        setEmailDetails(data);
      } else {
        setError(data?.error || "Failed to confirm task");
      }
    } catch (err: any) {
      console.error("Confirmation error:", err);
      setError(err.message || "Failed to confirm task completion");
    } finally {
      setLoading(false);
    }
  };

  if (!token) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
        <Card className="max-w-md w-full">
          <CardHeader>
            <div className="flex justify-center mb-4">
              <XCircle className="h-16 w-16 text-red-500" />
            </div>
            <CardTitle className="text-center">Invalid Link</CardTitle>
            <CardDescription className="text-center">
              This confirmation link is invalid or expired.
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    );
  }

  if (confirmed) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
        <Card className="max-w-md w-full">
          <CardHeader>
            <div className="flex justify-center mb-4">
              <img src={oricolLogo} alt="Oricol" className="h-16 w-auto" />
            </div>
            <div className="flex justify-center mb-4">
              <CheckCircle2 className="h-16 w-16 text-green-500" />
            </div>
            <CardTitle className="text-center">
              {emailDetails?.alreadyConfirmed ? "Already Confirmed" : "Thank You!"}
            </CardTitle>
            <CardDescription className="text-center">
              {emailDetails?.alreadyConfirmed 
                ? `This task was already confirmed ${emailDetails.confirmedBy ? `by ${emailDetails.confirmedBy}` : ''}`
                : emailDetails?.message || "Task confirmed successfully"
              }
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {emailDetails?.staffMemberName && (
              <div className="bg-muted p-4 rounded-lg">
                <p className="text-sm text-muted-foreground">Staff Member</p>
                <p className="font-semibold">{emailDetails.staffMemberName}</p>
              </div>
            )}
            {emailDetails?.confirmedAt && (
              <div className="bg-muted p-4 rounded-lg">
                <p className="text-sm text-muted-foreground">Confirmed At</p>
                <p className="font-semibold">
                  {new Date(emailDetails.confirmedAt).toLocaleString()}
                </p>
              </div>
            )}
            <div className="text-center text-sm text-muted-foreground pt-4">
              You can close this window now.
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <Card className="max-w-lg w-full">
        <CardHeader>
          <div className="flex justify-center mb-4">
            <img src={oricolLogo} alt="Oricol" className="h-16 w-auto" />
          </div>
          <CardTitle className="text-center">Confirm Task Completion</CardTitle>
          <CardDescription className="text-center">
            Please confirm that you have completed the requested setup
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="providerName">Your Name (Optional)</Label>
            <Input
              id="providerName"
              placeholder="e.g., Shaun Chetty"
              value={providerName}
              onChange={(e) => setProviderName(e.target.value)}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="notes">Additional Notes (Optional)</Label>
            <Textarea
              id="notes"
              placeholder="Add any notes about the setup completion..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={4}
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg flex items-start gap-2">
              <XCircle className="h-5 w-5 mt-0.5 flex-shrink-0" />
              <p className="text-sm">{error}</p>
            </div>
          )}

          <Button
            className="w-full"
            onClick={handleConfirm}
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Confirming...
              </>
            ) : (
              <>
                <CheckCircle2 className="mr-2 h-4 w-4" />
                Confirm Setup Complete
              </>
            )}
          </Button>

          <div className="text-center">
            <Link to="/" className="text-sm text-muted-foreground hover:text-foreground inline-flex items-center gap-1">
              <ArrowLeft className="h-3 w-3" />
              Back to Home
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
